// this route should be responsible for restricting access to reading / editing sales based on a user's role.
// right now, the RLS rules are pretty relaxed and anyone can read or edit any sale.
// this route will handle all requests to /api/sale as well as /api/sale/{id}

import {NextRequest, NextResponse} from "next/server";
import {Database, getEmployeeFromAuthUser, getRoleFromEmployee, getSupabaseRouteHandlerClient} from "@/lib/database";
import {createClient} from "@supabase/supabase-js";
import {cookies} from "next/headers";


const formatted_query_string =
    `
      EmployeeID,
      Employees (
          Avatar,
          Name,
          Email,
          EmployeeNumber,
          Role
      ),
        ActualCashValue,
        CustomerID,
        DaysInStock,
        DealerCost,
        EmployeeID,
        FinancingID,
        Financing (
          Method
         ),
        FinAndInsurance,
        GrossProfit,
        LotPack,
        NewSale,
        ROI,
        SaleTime,
        StockNumber,
        Total,
        TradeInID,
        VehicleMake
    `

// handle retrieving a single sale, or all the sales. Protects sales from being read by users with no permission.
// TODO need to update monthlySales too or remove them and use queries!!
export async function GET(request: NextRequest, { params }: {params: {id: string[]}}) {
  const searchParams = request.nextUrl.searchParams
  const supabase =
      getSupabaseRouteHandlerClient(cookies())
  const {data: {session}} = await supabase.auth.getSession();
  const employee = await getEmployeeFromAuthUser(supabase, session!.user)
  const role = await getRoleFromEmployee(supabase, employee);

  if (!role.ReadPermission) {
    return NextResponse.json({error: "Forbidden"}, {status: 401});
  }

  const supabaseAdmin =
      createClient<Database>(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.SUPABASE_SERVICE_KEY!)

  if (searchParams.get("type") === "formatted") { /* formatted -- for database-provider */
    if (!params.id) {
      const dbResult = await supabaseAdmin
          .from('Sales')
          .select(formatted_query_string)
          .order('SaleTime', { ascending: false })
      return NextResponse.json(dbResult);
    } else {
      const dbResult = await supabaseAdmin
          .from('Sales')
          .select(formatted_query_string)
          .in('id', params.id)
          .order('SaleTime', { ascending: false })
      return NextResponse.json(dbResult);
    }
  } else { /* default -- direct from table */
    if (!params.id) {
      const dbResult = await supabaseAdmin
          .from('Sales')
          .select()
          .order('SaleTime', { ascending: false })
      return NextResponse.json(dbResult);
    } else {
      const dbResult = await supabaseAdmin
          .from('Sales')
          .select()
          .in('id', params.id)
          .order('SaleTime', { ascending: false })
      return NextResponse.json(dbResult);
    }
  }

}

// handle new sale input to database
export async function POST(request: NextRequest) {
  const supabase = getSupabaseRouteHandlerClient(cookies());
  const {data: {session}} = await supabase.auth.getSession();
  const employee = await getEmployeeFromAuthUser(supabase, session!.user)
  const role = await getRoleFromEmployee(supabase, employee);

  // reject unauthorized users
  if (!role.WritePermission) {
    return NextResponse.json({error: "Forbidden"}, {status: 401});
  }

  // otherwise, setup admin client and create new sale.
  const supabaseAdmin =
      createClient<Database>(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.SUPABASE_SERVICE_KEY!)

  // TODO need to make this return a better status, maybe returning the item as well. Needs to be done on supabase RPC side.
  const res = await supabaseAdmin.rpc("create_new_sale", {sale: await request.json()});
  return new Response(null, {
    status: res.status,
  })
}

export function PATCH(request: Request) {
  return NextResponse.json({error: "Not yet implemented."}, {status: 405})
}

export function DELETE(request: Request) {
  return NextResponse.json({error: "Not yet implemented."}, {status: 405})
}
