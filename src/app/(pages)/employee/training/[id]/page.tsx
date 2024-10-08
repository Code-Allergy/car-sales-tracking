'use client'

import React, {useEffect} from 'react';
import {getReferencePagesById, getSupabaseBrowserClient, ReferencePage} from "@/lib/database";
import {DbResult} from "@/lib/types";
import {Separator} from "@/components/ui/separator";
import {Button} from "@/components/ui/button";

const supabase = getSupabaseBrowserClient();

function Page(props: any) {
    const id = props.params.id;
    const [page, setPage] = React.useState<ReferencePage>();


    // todo -- error prone calls..
    useEffect(() => {
        getReferencePagesById(supabase, id)
            .then((res) => {
                setPage(res as DbResult<typeof page>)
            })
    }, [id]);

    return (
        <div className="space-y-6 p-2 rounded-lg">
            {page && <h3 className="text-lg font-medium p-4 rounded-xl">{page.pagename}</h3>}
            <Separator />
            <div className="space-y-6">
                <p className="text-sm text-muted-foreground">{page?.pagebody}</p>
            </div>
        </div>
    );
}

export default Page;
