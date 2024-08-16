'use client'

import React, {useEffect, useState} from 'react';
import {
    Employee,
    ReferencePage,
    Sale,
    Task,
    getReferencePages,
    getSupabaseBrowserClient, getTasks, getSales, getAllTasksByAssignee,
} from "@/lib/database";
import {DateRange} from "react-day-picker";
import useAuth from "@/hooks/use-auth";
import {subDays} from "date-fns";
import {filterSalesByDate, filterTasksByStartDate} from "@/lib/utils";
import {errorToast} from "@/lib/toasts";


type EmployeeContextProps = {
    tasks?: Task[];
    sales?: Sale[];
    date?: DateRange;
    setDate?: React.Dispatch<React.SetStateAction<DateRange | undefined>>;
    employee?: Employee | null;
    referencePage?: ReferencePage[]
    // notify?: boolean
}

const supabase = getSupabaseBrowserClient()

const EmployeeContext = React.createContext<EmployeeContextProps | undefined>(undefined);

export function useEmployee(): EmployeeContextProps {
    const context = React.useContext(EmployeeContext);
    if (!context) throw new Error('useEmployee must be used within a EmployeeProvider');
    return context;
}

interface EmployeeProviderProps {
    children: React.ReactNode;
}

export const EmployeeProvider: React.FC<EmployeeProviderProps> = ({children}) => {
    const [allTasks, setAllTasks] = useState<Task[]>([]);
    const [allSales, setAllSales] = useState<Sale[]>([]);
    const [tasks, setTasks] = useState<Task[]>([]);
    const [sales, setSales] = useState<Sale[]>();
    const [referencePage, setReferencePage] = useState<ReferencePage[]>()
    const {employee, user, session} = useAuth()

    const [date, setDate] = React.useState<DateRange | undefined>({
        from: new Date(2023, 2, 28),
        to: new Date(2023, 8, 28),
    })


    useEffect(() => {
        fetch("/api/task", { method: "GET" })
            .then(response => response.json())
            .then(data => data.data)
            .then((res) => {
                setAllTasks(res as Task[])
                console.log(res)
        }).catch(e => {
            errorToast("Failed to load tasks.")
            console.error(e);
        })
        getSales()
            .then((res) => {
                setAllSales(res)
            })
            .catch(e => {
                errorToast("Failed to load sales.")
                console.error(e);
            })
        getReferencePages(supabase)
            .then((res) => {
                setReferencePage(res)
            })
            .catch(e => {
                errorToast("Failed to load sales.")
                console.error(e);
            })
    }, [employee])

    useEffect(() => {
        setSales(filterSalesByDate(date, allSales))
        setTasks(filterTasksByStartDate(allTasks, date))
    }, [allSales, allTasks, date])

    return (
        <EmployeeContext.Provider value={{tasks, sales, date, setDate, employee, referencePage}}>
            {children}
        </EmployeeContext.Provider>
    );
}

