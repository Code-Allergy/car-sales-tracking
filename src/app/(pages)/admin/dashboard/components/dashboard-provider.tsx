'use client'
import React, {createContext, PropsWithChildren, useEffect, useState} from 'react';
import {subDays} from "date-fns";
import {DateRange} from "react-day-picker";
import {
    Employee,
    getAllEmployees, getFormattedSales, getGoals, getReferencePages, getSales,
    getSupabaseBrowserClient, ReferencePage,
    Sale,
    SalesGoal
} from "@/lib/database";
import {SaleWithEmployeeAndFinancingType} from "@/lib/types";
import useAuth from "@/hooks/use-auth";
import {PostgrestError} from "@supabase/supabase-js";
import {filterSalesByDate, filterSalesByEmployee} from "@/lib/utils";
import {errorToast} from "@/lib/toasts";

type DashBoardContextProps = {
    saleWithEmployeeAndFinancing?: SaleWithEmployeeAndFinancingType[];
    mySales?: SaleWithEmployeeAndFinancingType[];
    data?: Sale[];
    salesGoal?: SalesGoal[];
    employees?: Employee[];
    date?: DateRange;
    setDate?: React.Dispatch<React.SetStateAction<DateRange | undefined>>;
    referencePage?: ReferencePage[]
    isLoading?: boolean
}

const supabase = getSupabaseBrowserClient()
export const DashboardContext = createContext<DashBoardContextProps | undefined>(undefined);

export function useDashboard(): DashBoardContextProps {
    const context = React.useContext(DashboardContext);
    if (!context) throw new Error('useDashboard must be used within a DashboardProvider'+ window.location.pathname.toString());
    return context;
}
export const DashboardProvider: React.FC<PropsWithChildren> = ({children}) => {
    const [filteredSales, setFilteredSales] = useState<Sale[]>();
    const [employees, setEmployees] = useState<Employee[]>();
    const [sales, setSales] = useState<Sale[]>([])
    const [saleWithEmployeeAndFinancing, setSaleWithEmployeeAndFinancing] = useState<SaleWithEmployeeAndFinancingType[]>();
    const [salesGoal, setSalesGoal] = useState<SalesGoal[]>();
    const [mySales, setMySales] = useState<SaleWithEmployeeAndFinancingType[]>();
    const [referencePage, setReferencePage] = useState<ReferencePage[]>();
    const [isLoading, setIsLoading] = useState<boolean>(false);
    const {employee} = useAuth()

    useEffect(() => { // todo - this is a hacky way to do this. need to revisit this.
        setIsLoading(true)
        employee &&
        filteredSales &&
        employees &&
        sales &&
        saleWithEmployeeAndFinancing &&
        salesGoal &&
        mySales &&
        referencePage &&
        setIsLoading(false)
    }, [employee, filteredSales, employees, sales, saleWithEmployeeAndFinancing, salesGoal, mySales, referencePage]);


    const [date, setDate] = React.useState<DateRange | undefined>({
        from: new Date(2023, 2, 28),
        to: new Date(2023, 8, 28),
    })


    // get all employees, sales, goals and reference pages on initial provider load
    useEffect(() => {
        getAllEmployees(supabase)
            .then(res => setEmployees(res as Employee[]))
            .catch(err => {
                errorToast("Failed to get Employees.")
                console.error(err);
            })

        getSales()
            .then((sales) => setSales(sales))
            .catch(err => {
                errorToast("Failed to load Sales.");
                console.error(err);
            });

        getGoals()
            .then((goals) => setSalesGoal(goals))
            .catch(err => {
                errorToast("Failed to load Goals.");
                console.error(err);
            });

        getReferencePages(supabase)
            .then((res) => {
                setReferencePage(res as ReferencePage[])
            }).catch(err => {
                errorToast("Failed to load Reference Pages")
            console.error(err);
        })
    }, []);

    // update filtered sales on date change
    useEffect(() => {
        setFilteredSales(filterSalesByDate(date, sales))
    }, [date, sales]);


    useEffect(() => {
        getFormattedSales()
            .then((sales) => {
                setSaleWithEmployeeAndFinancing(sales)
                setMySales(filterSalesByEmployee(sales, employee!))
            })
            .catch(err => {
                errorToast("Failed to load formatted Sales.");
                console.error(err);
            });
    }, [employee]);

    return (
        <DashboardContext.Provider
            value={{data:filteredSales,
                salesGoal,
                employees,
                date,
                saleWithEmployeeAndFinancing,
                mySales,
                setDate,
                referencePage
                , isLoading}}>
            {children}
        </DashboardContext.Provider>
    );
};
