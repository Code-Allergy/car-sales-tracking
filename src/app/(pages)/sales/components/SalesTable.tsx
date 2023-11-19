'use client'

import {
    Column,
    ColumnDef,
    ColumnFiltersState, flexRender,
    getCoreRowModel, getFilteredRowModel,
    getPaginationRowModel, getSortedRowModel,
    SortingState,
    useReactTable
} from "@tanstack/react-table";
import React, {useEffect, useState} from "react";
import {Input} from "@/components/ui/input";
import {Table, TableBody, TableCell, TableHead, TableHeader, TableRow} from "@/components/ui/table";
import {Select, SelectContent, SelectItem, SelectTrigger, SelectValue} from "@/components/ui/select";
import {Button} from "@/components/ui/button";
import {
    ChevronLeftIcon,
    ChevronRightIcon,
    DoubleArrowLeftIcon,
    DoubleArrowRightIcon
} from "@radix-ui/react-icons";
import {Checkbox} from "@/components/ui/checkbox";
import {Employee, Tables, Sale, getSupabaseBrowserClient} from "@/lib/database";
import {ArrowUpDown, Plus} from "lucide-react";
import {Badge} from "@/components/ui/badge";

import {format} from "date-fns";
import {Tooltip, TooltipContent, TooltipProvider, TooltipTrigger} from "@/components/ui/tooltip";
import {DbResult} from "@/lib/types";
import DataTable from "@/components/tables/DataTable";

import FormModal from "@/components/dialogs/FormModal";
import {DropDownMenu} from "@/admin/sales/components/drop-down-menu";

// todo align rows and columns

/**
 * Component used to render sales page table at `/sales`
 * @group React Components
 */
export default function SalesTable() {
    const [loading, setLoading] = useState(true);
    const [sales, setSales] = useState<Sale[]>([]);
    const [employees, setEmployees] = useState<Employee[]>([]);
    const [sorting, setSorting] = useState<SortingState>([])
    const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([])
    const [showSaleDialog, setShowSaleDialog] = useState<boolean>(false)

    const supabase = getSupabaseBrowserClient();
    // const [salesModal, setSalesModal] = useState(false);

    useEffect(() => {
        function fetchData() {
            return Promise.all([
                supabase.from('Sales').select(),
                supabase.from('Employees').select(),
            ]);
        }

        async function loadData() {
            try {
                setLoading(true);
                const [salesData, employeeData] = await fetchData();
                const {data: sales, count: salesCount, error: salesError} = salesData;
                const {data: employees, count: employeeCount, error: employeeError} = employeeData;
                console.log('sales: ', sales)
                console.log('employees: ', employees)

                if (salesError || employeeError) {
                    console.error("Supabase error: ", (salesError ?? employeeError));
                    throw new Error("Failed to load sales or employees data.");
                }
                setSales(sales);
                setEmployees(employees);
            } catch (error) {
                console.error(error);
            } finally {
                setLoading(false);
            }
        }
        loadData().then(() => setLoading(false));
    }, [supabase]);

    // function updateSales(sale: Sale) {
    //   const originalSales = [...sales]
    //   const updatedSales = originalSales
    //       .map((oldSale) => oldSale.id === sale.id ? sale: oldSale)
    //   setSales(updatedSales)
    // }
    function tooltip(cell:string){
        return (
            <TooltipProvider>
                <Tooltip>
                    <TooltipTrigger asChild>
                        <p className={'max-w-[200px] text-sm truncate'}>
                            {cell}
                        </p>
                    </TooltipTrigger>
                    <TooltipContent>
                        <p>{cell}</p>
                    </TooltipContent>
                </Tooltip>
            </TooltipProvider>

        )
    }

    // todo ts:any
    async function onSubmit(data:any) {
        data["EmployeeID"] = '4ff2a2d7-09a1-4d26-81e1-55fcf9b0f49b'; // replace this with the uuid of current employee
        data["Total"] = 5;

        // @ts-ignore
        // await supabase.rpc("create_new_sale", {sale: data});
        await fetch(`http://localhost:3000/api/sale`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify(data),
        })
    }

    function SortButton(name: string, column: Column<Tables<'Sales'>>) {
        // todo does not work for employee names

        return (
            <Button
                size="sm"
                variant={"ghost"}
                onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
            >
                {name}
                <ArrowUpDown className="ml-1 h-3.5 w-3.5 text-muted-foreground/70"/>
            </Button>
        )
    }

    const columns: ColumnDef<Tables<'Sales'>, Employee>[] = [
        {
            id: "select",
            header: ({table}) => (
                <Checkbox
                    checked={table.getIsAllPageRowsSelected()}
                    onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
                    aria-label="Select all"
                    className="translate-y-[2px]"
                />
            ),
            cell: ({row}) => (
                <Checkbox
                    checked={row.getIsSelected()}
                    onCheckedChange={(value) => row.toggleSelected(!!value)}
                    aria-label="Select row"
                    className="translate-y-[2px]"
                />
            ),
            enableSorting: false,
            enableHiding: false,
        },
        {
            accessorKey: "SaleTime",
            // header: ({column}) => SortButton("SaleTime", column),
            header: ({column}) => SortButton("SaleTime", column),
            cell: ({row}) => {
                return (
                    <p className={'text-sm min-w-fit'}>
                        {/*{new Date(row.original.SaleTime || new Date()).toDateString()}*/}
                        {/*{format(new Date(row.original.SaleTime || new Date()), 'yyyy-MMM-dd')}*/}
                        {format(new Date(row.original.SaleTime || new Date()), "LLL dd, y")}
                    </p>
                )
            },
        },
        // {
        //     accessorKey: "EmployeeID",
        //     header: ({column}) => SortButton("EmployeeID", column)
        // },
        {
            accessorKey: "Name",
            header: ({column}) => SortButton("Name", column),
            cell: ({row}) => {
                // return employees.find((employee) => employee.id === row.original.EmployeeID)?.Name
                return (
                    <div className="flex space-x-2 ml-1">
                        <Badge variant="outline">
                            <span className="max-w-[200px] truncate font-medium">
                                {tooltip(employees.find((employee) => employee.id === row.original.EmployeeID)?.Name || 'Employee Name')}
                            </span>
                        </Badge>
                    </div>
                )
            },
        },
        {
            accessorKey: "VehicleMake",
            header: ({column}) => SortButton("VehicleMake", column),
            cell: ({row}) => {
                return (tooltip(row.original.VehicleMake))
            }
        },
        {
            accessorKey: "ActualCashValue",
            header: ({column}) => SortButton("ActualCashValue", column),
            cell: ({row}) => `$${row.original.ActualCashValue.toLocaleString()}`,
        },
        {
            accessorKey: "GrossProfit",
            header: ({column}) => SortButton("GrossProfit", column),
            cell: ({row}) => `$${row.original.GrossProfit.toLocaleString()}`,
        },
        {
            accessorKey: "FinAndInsurance",
            header: ({column}) => SortButton("FinAndInsurance", column),
            cell: ({row}) => `$${row.original.FinAndInsurance.toLocaleString()}`,
        },
        {
            accessorKey: "Holdback",
            header: ({column}) => SortButton("Holdback", column),
            cell: ({row}) => {return row.original.Holdback ? `$${row.original.Holdback.toLocaleString()}`: '0'},
        },
        {
            accessorKey: "Total",
            header: ({column}) => SortButton("Total", column),
            cell: ({row}) => `$${row.original.Total.toLocaleString()}`,
        },
        {
            id: "actions",
            cell: ({row}) => DropDownMenu({row, sales, setSales}),
        },
    ]

        const table = useReactTable({
        data: sales,
        columns,
        getCoreRowModel: getCoreRowModel(),
        onSortingChange: setSorting,
        getPaginationRowModel: getPaginationRowModel(),
        onColumnFiltersChange: setColumnFilters,
        getFilteredRowModel: getFilteredRowModel(),
        getSortedRowModel: getSortedRowModel(),
        state: {
            sorting,
            columnFilters
        },
        enableSorting: true,
        enableColumnFilters: true,
    })

    const newRow: Sale = {
        id: table.getRowModel().rows.length + 1,
        EmployeeID: '1',
        SaleTime: new Date().toDateString(),
        VehicleMake: 'VehicleMake',
        ActualCashValue: 0,
        GrossProfit: 0,
        FinAndInsurance: 0,
        Holdback: 0,
        Total: 0,
        StockNumber: '12345',
        CustomerID: 0,
        FinancingID: 0,
        TradeInID: 0,
        NewSale: false,
        LotPack: 0,
        DaysInStock: 0,
        DealerCost: 0,
        ROI: 0,
    };



    return (
        <DataTable table={table} loading={loading}>
            <Input
                placeholder="Filter sales..."
                value={(table.getColumn("Name")?.getFilterValue() as string) ?? ""}
                onChange={(event) => table.getColumn("Name")?.setFilterValue(event.target.value)}
                className="max-w-sm"
            />
            <div className="flex items-center space-x-2 w-full">
                <Button
                     size="sm"
                     variant="outline"
                     className="ml-auto hidden h-8 lg:flex"
                     onClick={() => {
                         const setFunc = (old: Sale[]) => [...old, newRow];
                         setSales(setFunc as DbResult<Sale[]>);
                         table.setSorting([{id: "SaleTime", desc: false,}])
                     }}
                    // onClick={() => console.log()}
                >
                 <Plus className="mr-2 h-4 w-4" />
                 Add Row
                </Button>
                <Button
                 size="sm"
                 variant="outline"
                 className="ml-auto hidden h-8 lg:flex"
                 onClick={() => {
                     // save
                 }}
             >
                     save
                 </Button>
             </div>
            {/* tmp */}
            {/*<FormModal title={"Create Sale"} showDialog={showSaleDialog} setShowDialog={setShowSaleDialog} onSubmit={onSubmit}>*/}
            {/*    <AddSalesRowDialog/>*/}
            {/*</FormModal>*/}
        </DataTable>

    )
}


// interface DataTableProps<TData, TValue> {
//     columns: ColumnDef<TData, TValue>[]
//     defaultData: TData[]
//     loading?: boolean
// }
//
// export function DataTable<TData, TValue>({defaultData, columns, loading}: DataTableProps<TData, TValue>) {
//     const [sorting, setSorting] = useState<SortingState>([])
//     const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([])
//     const pageSizes = [10, 25, 50, 100]
//     const ref = React.useRef<HTMLTableSectionElement>(null)
//     const [data, setData] = useState( defaultData);
//
//     const table = useReactTable({
//         data,
//         columns,
//         getCoreRowModel: getCoreRowModel(),
//         onSortingChange: setSorting,
//         getPaginationRowModel: getPaginationRowModel(),
//         onColumnFiltersChange: setColumnFilters,
//         getFilteredRowModel: getFilteredRowModel(),
//         getSortedRowModel: getSortedRowModel(),
//         state: {
//             sorting,
//             columnFilters
//         },
//         enableSorting: true,
//         enableColumnFilters: true,
//     })
//     const newRow: Sale = {
//         id: table.getRowModel().rows.length + 1,
//         EmployeeID: '1',
//         SaleTime: new Date().toDateString(),
//         VehicleMake: 'VehicleMake',
//         ActualCashValue: 0,
//         GrossProfit: 0,
//         FinAndInsurance: 0,
//         Holdback: 0,
//         Total: 0,
//         StockNumber: '12345',
//         CustomerID: 0,
//         FinancingID: 0,
//         TradeInID: 0,
//         NewSale: false,
//         LotPack: 0,
//         DaysInStock: 0,
//         DealerCost: 0,
//         ROI: 0,
//     };
//
//     return (
//         <div className="space-y-4">
//             <div className="flex items-center">
//                 <Input
//                     placeholder="Filter sales..."
//                     value={(table.getColumn("Name")?.getFilterValue() as string) ?? ""}
//                     onChange={(event) => table.getColumn("Name")?.setFilterValue(event.target.value)}
//                     className="max-w-sm"
//                 />
//                 <div className="flex items-center space-x-2 w-full">
//                     <Button
//                         size="sm"
//                         variant="outline"
//                         className="ml-auto hidden h-8 lg:flex"
//                         onClick={() => {
//                             const setFunc = (old: Sale[]) => [...old, newRow];
//                             setData(setFunc as DbResult<Sale[]>);
//                             table.setSorting([{id: "SaleTime", desc: false,}])
//                         }}
//                     >
//                         <Plus className="mr-2 h-4 w-4" />
//                         Add Row
//                     </Button>
//                     <Button
//                         size="sm"
//                         variant="outline"
//                         className="ml-auto hidden h-8 lg:flex"
//                         onClick={() => {
//                             // save
//                         }}
//                     >
//                         save
//                     </Button>
//                 </div>
//             </div>
//             <div className="rounded-md border">
//                 <Table>
//                     <TableHeader>
//                         {table.getHeaderGroups().map((headerGroup) => (
//                             <TableRow key={headerGroup.id}>
//                                 {headerGroup.headers.map((header) =>
//                                     <TableHead key={header.id}>
//                                         {header.isPlaceholder
//                                             ? null
//                                             : flexRender(
//                                                 header.column.columnDef.header,
//                                                 header.getContext()
//                                             )}
//                                     </TableHead>
//                                 )}
//                             </TableRow>
//                         ))}
//                     </TableHeader>
//                     <TableBody ref={ref}>
//                         {table.getRowModel().rows?.length ? (
//                             table.getRowModel().rows.map((row) => (
//                                 <TableRow
//                                     key={row.id}
//                                     data-state={row.getIsSelected() && "selected"}
//                                 >
//                                     {row.getVisibleCells().map((cell) => (
//                                         <TableCell key={cell.id}>
//                                             {flexRender(cell.column.columnDef.cell, cell.getContext())}
//                                         </TableCell>
//                                     ))}
//                                 </TableRow>
//                             ))
//                         ) : (
//                             <TableRow>
//                                 <TableCell colSpan={columns.length} className="h-24 text-center">
//                                     {/* Todo */}
//                                     No result? refresh..?
//                                     {/*<div className="flex items-center justify-center h-24">*/}
//                                     {/*    <div className="flex items-center space-x-2">*/}
//                                     {/*        <div className="w-4 h-4 bg-accent rounded-full animate-bounce"/>*/}
//                                     {/*        <div className="w-4 h-4 bg-accent rounded-full animate-bounce delay-75"/>*/}
//                                     {/*        <div className="w-4 h-4 bg-accent rounded-full animate-bounce delay-150"/>*/}
//                                     {/*    </div>*/}
//                                     {/*</div>*/}
//                                 </TableCell>
//                             </TableRow>
//                         )}
//                     </TableBody>
//                 </Table>
//             </div>
//
//             {/* Pagination */}
//             <div className="flex items-center justify-between px-2">
//                 <div className="flex-1 text-sm text-muted-foreground">
//                     {table.getFilteredSelectedRowModel().rows.length} of {" "}
//                     {table.getFilteredRowModel().rows.length} item(s) selected.
//                 </div>
//                 <div className="flex items-center space-x-6 lg:space-x-8">
//                     <div className="flex items-center space-x-2">
//                         <p className="text-sm font-medium">Rows per page</p>
//                         <Select
//                             value={`${table.getState().pagination.pageSize}`}
//                             onValueChange={(value) => {
//                                 table.setPageSize(Number(value))
//                             }}
//                         >
//                             <SelectTrigger className="h-8 w-[70px]">
//                                 <SelectValue placeholder={table.getState().pagination.pageSize}/>
//                             </SelectTrigger>
//                             <SelectContent>
//                                 {pageSizes.map((pageSize) => (
//                                     <SelectItem key={pageSize} value={`${pageSize}`}>
//                                         {pageSize}
//                                     </SelectItem>
//                                 ))}
//                             </SelectContent>
//                         </Select>
//                     </div>
//                     <div className="flex w-[100px] items-center justify-center text-sm font-medium">
//                         Page {table.getState().pagination.pageIndex + 1} of{" "}
//                         {table.getPageCount()}
//                     </div>
//                     <div className="flex items-center space-x-2">
//                         <Button
//                             variant="outline"
//                             className="hidden h-8 w-8 p-0 lg:flex"
//                             onClick={() => table.setPageIndex(0)}
//                             disabled={!table.getCanPreviousPage()}
//                         >
//                             <span className="sr-only">Go to first page</span>
//                             <DoubleArrowLeftIcon className="h-4 w-4"/>
//                         </Button>
//                         <Button
//                             variant="outline"
//                             className="h-8 w-8 p-0"
//                             onClick={() => table.previousPage()}
//                             disabled={!table.getCanPreviousPage()}
//                         >
//                             <span className="sr-only">Go to previous page</span>
//                             <ChevronLeftIcon className="h-4 w-4"/>
//                         </Button>
//                         <Button
//                             variant="outline"
//                             className="h-8 w-8 p-0"
//                             onClick={() => table.nextPage()}
//                             disabled={!table.getCanNextPage()}
//                         >
//                             <span className="sr-only">Go to next page</span>
//                             <ChevronRightIcon className="h-4 w-4"/>
//                         </Button>
//                         <Button
//                             variant="outline"
//                             className="hidden h-8 w-8 p-0 lg:flex"
//                             onClick={() => table.setPageIndex(table.getPageCount() - 1)}
//                             disabled={!table.getCanNextPage()}
//                         >
//                             <span className="sr-only">Go to last page</span>
//                             <DoubleArrowRightIcon className="h-4 w-4"/>
//                         </Button>
//                     </div>
//                 </div>
//             </div>
//         </div>
//     )
// }



