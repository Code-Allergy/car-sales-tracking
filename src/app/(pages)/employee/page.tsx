'use client'

import React, {Suspense} from 'react';
import {useEmployee} from "@/employee/employee-components/employee-provider";
import CalendarDateRangePicker from "@/admin/dashboard/components/date-range-picker";
import {Button} from "@/components/ui/button";
import {DynamicChart} from "@/components/dynamic-chart";
import TasksQuickView from "@/employee/employee-components/tasks-quick-view";

function Page() {
    const {
        employee,
        tasks,
        sales,
        date,
        setDate
    } = useEmployee()

    return (
        <Suspense fallback={null}>
            <div className="flex-col md:flex">
                <div className="flex-1 space-y-4 p-8 pt-6">
                    <div className="flex items-center justify-between space-y-2">
                        <div className="flex items-center justify-between space-y-2">
                            <div>
                                <h2 className="text-2xl font-bold tracking-tight">OverView</h2>
                                <p className="text-muted-foreground">
                                    Welcome back, {employee?.Name}
                                </p>
                            </div>
                        </div>
                        <div className="flex items-center space-x-2">
                            <CalendarDateRangePicker date={date} setDate={setDate}/>
                            <Button>Download</Button>
                        </div>
                    </div>
                    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
                        {sales &&
                            <DynamicChart
                                className="col-span-4"
                                data={sales!}
                                date={date}
                                title={'Sales'}
                            />
                        }
                        <TasksQuickView tasks={tasks}/>
                    </div>
                </div>
            </div>
        </Suspense>
    );
}

export default Page;
