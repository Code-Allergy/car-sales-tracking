// rename or find somewhere for this

import { Row } from "@tanstack/react-table";
import React, { useState } from "react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuShortcut,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Button } from "@/components/ui/button";
import { MoreHorizontal } from "lucide-react";
import FormModal from "@/components/dialogs/form-modal";
import { Sale } from "@/lib/database";
import { RowActionDialog } from "./dialogs/row-action-dialog";
import { errorToast } from "@/lib/toasts";
type Props = {
  row: Row<Sale>;
};

export function SalesDropDownMenu({ row }: Props) {
  const [salesModal, setSalesModal] = useState(false);

  // TODO
  // function updateSales(sale: Sale) {
  //     const originalSales = [...sales]
  //     const updatedSales = originalSales
  //         .map((oldSale) => oldSale.id === sale.id ? sale: oldSale)
  //     setSales(updatedSales)
  // }

  return (
    <>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" className="h-8 w-8 p-0">
            <span className="sr-only">Open menu</span>
            <MoreHorizontal className="h-4 w-4" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuLabel>Actions</DropdownMenuLabel>
          <DropdownMenuSeparator />
          <DropdownMenuItem
            onClick={() =>
              navigator.clipboard.writeText(JSON.stringify(row.original))
            }
          >
            Copy
          </DropdownMenuItem>
          <DropdownMenuItem
            onClick={() => {
              setSalesModal(true);
            }}
          >
            <span>Edit</span>
          </DropdownMenuItem>
          <DropdownMenuSeparator />

          <DropdownMenuItem
            onClick={async () => {
              const result = await fetch(`/api/sale/${row.original.id}`, {
                method: "DELETE",
              });
              const resultBody = await result.json();
              if (resultBody.error) {
                errorToast(resultBody.error);
              }
            }}
          >
            Delete
            <DropdownMenuShortcut>⌘⌫</DropdownMenuShortcut>
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>{" "}
      {/* TODO  */}
      {salesModal && (
        <FormModal
          title={"Sale"}
          showDialog={salesModal}
          setShowDialog={setSalesModal}
          onSubmit={(res) => console.log("sale patch:", res)}
        >
          <RowActionDialog sale={row.original} />
        </FormModal>
      )}
    </>
  );
}
