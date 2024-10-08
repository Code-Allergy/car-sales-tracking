'use client'

import React, {useEffect, useState} from 'react';
import {Separator} from "@/components/ui/separator";
import {
    Employee,
    getAllEmployees,
    getAllRoles,
    getSupabaseBrowserClient, Role
} from "@/lib/database";
import {Button} from "@/components/ui/button";
import EmployeeAvatar from "@/components/employee-avatar";
import {Badge} from "@/components/ui/badge";
import {Input} from "@/components/ui/input";
import {useRouter} from "next/navigation";
import {ScrollArea, ScrollBar} from "@/components/ui/scroll-area";

function UpdateUserPage() {
    const supabase = getSupabaseBrowserClient();
    const [employees, setEmployees] = useState<Employee[]>();
    const [roles, setRoles] = useState<Role[]>();
    const router = useRouter()
    const [searchTerm, setSearchTerm] = useState("");

    useEffect(() => {
        getAllEmployees(supabase).then((res) => {
            res?.sort((a, b) => {
                return a.Role - b.Role
            })
            setEmployees(res as Employee[])
            return res
        }).catch((err) => {
            console.error(err)
        })

        getAllRoles(supabase).then((res) => {
            setRoles(res as Role[])
            return res
        }).catch((err) => {
            console.error(err)
        })
    }, [supabase]);

    const filteredEmployees = employees?.filter(employee =>
        employee.Name.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
      <div className="space-y-6">
            <div className={'flex flex-col md:flex-row justify-between'}>
                <div className={'w-full md:flex md:flex-col'}>
                    <h3 className="text-lg font-medium">Update User</h3>
                    <p className="text-sm text-muted-foreground">Click on a user to update.</p>
                </div>
                <Input placeholder={'Search'} value={searchTerm} onChange={e => setSearchTerm(e.target.value)}/>
            </div>
            <Separator/>
            <ScrollArea className={'h-[800px]'}>
                {filteredEmployees?.map((employee) => {
                    return (
                        <div key={employee.id}
                             className="flex items-center border-b justify-between space-x-4 p-3 shadow-sm cursor-pointer hover:bg-accent mr-4 my-2"
                             onClick={() => {
                                 router.push(`/admin/settings/user-settings/update/${employee.id}`)
                             }}
                        >
                                <div className="flex items-center space-x-4 w-full">
                                    <Button variant="ghost" className="relative h-8 w-8 rounded-full">
                                        <EmployeeAvatar employee={employee}/>
                                    </Button>
                                    <div>
                                        <p className="text-sm font-medium leading-none">
                                            {employee.Name}
                                        </p>
                                        <p className="text-sm text-muted-foreground">{employee.Email}</p>
                                    </div>
                                </div>
                            <Badge variant={'outline'} className={'min-w-fit'}>{
                                roles?.filter((role) => {
                                    return role.id === employee.Role
                                })[0].RoleName
                            }</Badge>
                        </div>
                    )
                })}
                <ScrollBar/>
            </ScrollArea>
        </div>
    );
}

export default UpdateUserPage;
