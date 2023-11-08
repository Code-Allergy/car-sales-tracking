'use client'


// todo maybe add hovers so it is clear about what each role does?
import {Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage} from "@/components/ui/form";
import {Switch} from "@/components/ui/switch";
import {Button} from "@/components/ui/button";
import {useForm, UseFormReturn} from "react-hook-form";
import {z} from "zod";
import {Input} from "@/components/ui/input";
import {useFormModalContext} from "@/components/FormModal";
import {zodResolver} from "@hookform/resolvers/zod";
import {DialogBody} from "next/dist/client/components/react-dev-overlay/internal/components/Dialog";
import {DialogFooter} from "@/components/ui/dialog";
import DialogCloseButton from "@/components/DialogCloseButton";

const role_options_config = [
  {
    label: "Read Access",
    name: "read",
    description: "Employee can view and read sales ",
    default: true
  },
  {
    label: "Create Access",
    name: "create",
    description: "Employee can create new sales ",
    default: true
  },
  {
    label: "Modify Own Sales",
    name: "modifySelf",
    description: "Employee can modify their own sales ",
    default: true
  },
  {
    label: "Modify All Sales",
    name: "modifyAll",
    description: "Employee can modify any sales in the system.",
    default: false
  },
  {
    label: "Employee Management",
    name: "employees",
    description: "Employee can manage employees ",
    default: false
  },
  {
    label: "Full Access",
    name: "admin",
    description: "Employee has full administrative access ",
    default: false
  },
]

const roles = Object.fromEntries(
    role_options_config.map((role) => [role.name, z.boolean()])
);
const role_defaults = Object.fromEntries(
    role_options_config.map((role) => [role.name, role.default])
);

const createRoleModalSchema = z.object({
  name: z.string()
      .min(1, "Role Name must not be empty")
      .max(255, "Role name exceeds limit"),
  ...roles
});

const RoleDialogOption = (
    {label,
      name,
      description,
      form}
        : {
      label: string,
      name: string,
      description: string,
      form: any }
) => (
    <FormField
        control={form.control}
        name={name}
        render={({field}) => (
            <FormItem className="flex flex-row items-center justify-between rounded-lg border p-3 shadow-sm">
              <div className="space-y-0.5 ">
                <FormLabel>{label}</FormLabel>
                <FormDescription>
                  {description}
                </FormDescription>
              </div>
              <FormControl>
                <Switch
                    checked={field.value}
                    onCheckedChange={field.onChange}
                    aria-readonly
                />
              </FormControl>
            </FormItem>
        )}
    />
)

const DialogFormInputField = ({form}: { form: UseFormReturn<z.infer<typeof createRoleModalSchema>> }) => (
    <FormField
        control={form.control}
        name="name"
        render={({ field }) => (
            <FormItem>
              <FormLabel>Role Name</FormLabel>
              <FormControl>
                <Input
                    placeholder="Name"
                    {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
        )}
    />
)

export function CreateRoleDialog({}) {
  const formContext = useFormModalContext()
  const form = useForm<z.infer<typeof createRoleModalSchema>>({
    resolver: zodResolver(createRoleModalSchema),
    defaultValues: {
      name: "",
      ...role_defaults
    }
  })

  return (
      <Form {...form}>
        <form onSubmit={form.handleSubmit((data) =>
            formContext?.onSubmit(data))} className="space-y-8">
          <DialogBody>
            <DialogFormInputField form={form}/>
            {role_options_config.map(option => (
                <div key={option.name} className="my-3">
                  <RoleDialogOption {...option} form={form} />
                </div>
            ))}
          </DialogBody>
          <DialogFooter>
            <DialogCloseButton/>
            <Button type={"submit"}>Create</Button>
          </DialogFooter>
        </form>
      </Form>
  )
}
