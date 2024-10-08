import React, {PropsWithChildren} from "react";
import {test_sales_set} from "@/tests/test_data";
import {DashboardContext} from "@/admin/dashboard/components/dashboard-provider"

type FakeDashboardProps = {
  startDate: Date,
  endDate: Date,
}

export const FakeDashboardProvider = ({children, startDate, endDate}: PropsWithChildren<FakeDashboardProps> ) => {
  const from = startDate ?? new Date();
  const to = endDate ?? new Date();
  const date = {to, from}

  const data = test_sales_set.filter(item => {
    const saleTime = new Date(item.SaleTime);
    return (saleTime >= from && saleTime <= to)
  });

  return (
      <DashboardContext.Provider value={{ data, date }}>
        {children}
      </DashboardContext.Provider>
  );
};