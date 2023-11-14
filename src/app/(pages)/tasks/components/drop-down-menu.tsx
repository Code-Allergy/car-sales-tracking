import {Row} from "@tanstack/react-table";
// import {Database, Sale} from "@/lib/database.types";
import React, {useState} from "react";
import {
    DropdownMenu,
    DropdownMenuContent, DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuSeparator, DropdownMenuShortcut,
    DropdownMenuTrigger
} from "@/components/ui/dropdown-menu";
import {Button} from "@/components/ui/button";
import {MoreHorizontal} from "lucide-react";
// import {AddRowDialog} from "@/app/(pages)/sales/components/AddRowDialog";
import FormModal from "@/components/FormModal";
import {getSupabaseBrowserClient, Sale, Task} from "@/lib/database";
import {AddSalesRowDialog} from "@/app/(pages)/sales/components/AddSalesRowDialog";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
    DialogTrigger
} from "@/components/ui/dialog";
import {AddTasksRowDialog} from "@/app/(pages)/tasks/components/AddTasksRowDialog";
// import {createClientComponentClient} from "@supabase/auth-helpers-nextjs";


type Props = {
    row: Row<Task>
    tasks: Task[]
    setTasks: (task: Task[]) => void
}

// TODO TS71007: Props must be serializable for components in the "use client" entry file, "setSales" is invalid

export function DropDownMenu({row, tasks, setTasks}: Props) {
    const supabase = getSupabaseBrowserClient();
    const [salesModal, setSalesModal] = useState(false);

    function updateTasks(task: Task) {
        const originalTasks = [...tasks]
        const updatedTasks = originalTasks
            .map((oldTask) => oldTask.id === task.id ? task: oldTask)
        setTasks(updatedTasks)
    }

    return (
        <>
            <DropdownMenu>
                <DropdownMenuTrigger asChild>
                    <Button variant="ghost" className="h-8 w-8 p-0">
                        <span className="sr-only">Open menu</span>
                        <MoreHorizontal className="h-4 w-4"/>
                    </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                    <DropdownMenuLabel>Actions</DropdownMenuLabel>
                    <DropdownMenuSeparator/>
                    <DropdownMenuItem onClick={() => navigator.clipboard.writeText(JSON.stringify(row.original))}>
                        Copy
                    </DropdownMenuItem>
                    <DropdownMenuItem onClick={()=>{setSalesModal(true)}}>
                        <span>Edit</span>
                    </DropdownMenuItem>
                    <DropdownMenuSeparator/>

                    <DropdownMenuItem onClick={() => {
                        row.original.id && supabase.from('Tasks').delete().eq('id', row.original.id).then(() => {
                            const originalTasks = [...tasks]
                            const updatedTasks = originalTasks.filter((oldTask) => oldTask.id !== row.original.id)
                            setTasks(updatedTasks)
                        })
                    }}>
                        Delete`
                        <DropdownMenuShortcut>⌘⌫</DropdownMenuShortcut>
                    </DropdownMenuItem>

                </DropdownMenuContent>
            </DropdownMenu>
            {salesModal &&
                <FormModal title={"Sale"} showDialog={salesModal} setShowDialog={setSalesModal} onSubmit={updateTasks}>
                    <AddTasksRowDialog task={row.original} />
                </FormModal>
            }
        {/*    if a user clicks edit but closes modal without saving what happens? memory leak? */}
        </>
    );
}
