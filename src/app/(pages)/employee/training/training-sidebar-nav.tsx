"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"

import {cn} from "@/lib/utils"
import { buttonVariants } from "@/components/ui/button"
import useAuth from "@/hooks/use-auth";

interface SidebarNavProps extends React.HTMLAttributes<HTMLElement> {
  items: {
    href: string
    title: string
  }[]
}

export function TrainingSidebarNav({ className, items, ...props }: SidebarNavProps) {
  const pathname = usePathname()
  return (
    <nav
      className={cn(
        "flex space-x-2 lg:flex-col lg:space-x-0 lg:space-y-1",
        className
      )}
      {...props}
    >
      <div>
        {items.map((item) => (
            <Link
                key={item.href}
                href={item.href}
                className={cn(
                    buttonVariants({ variant: "ghost" }),
                    pathname === item.href
                        ? "bg-muted hover:bg-muted"
                        : "hover:bg-transparent hover:underline",
                    "justify-start", "truncate w-full")}
            >
              {item.title}
            </Link>
        ))}

      </div>
    </nav>
  )
}
