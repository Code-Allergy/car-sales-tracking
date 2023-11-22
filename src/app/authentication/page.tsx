"use client";

// import { UserAuthForm } from "./components/user-auth-form"
import Image from "next/image";
import * as React from "react";
import ContainerLayout from "@/components/container-layout";
import dynamic from "next/dynamic";

const UserAuthForm = dynamic(() => import("./components/user-auth-form"));

/**
 * Allows the user to login using the {@link UserAuthForm} component.
 * @group Next.js Pages
 * @route `/authentication`
 */
export default function AuthenticationPage() {
  const random = Math.floor(Math.random() * 4) + 1;
  return (
    <ContainerLayout>
      <div className="container relative hidden h-[800px] flex-col items-center justify-center md:grid lg:max-w-none lg:grid-cols-2 lg:px-0 ">
        <Image
          src={"/images/logo.png"}
          alt={"icon"}
          width={120}
          height={50}
          className={"absolute right-4 top-4 md:right-8 md:top-8"}
        />
        <div className="relative hidden h-full flex-col bg-muted p-10 text-white dark:border-r lg:flex ">
          <Image
            src={`/images/img${random}.jpg`}
            alt={"decorative sidebar image"}
            fill
            sizes={"100%"}
            className={"grayscale-[25%]"}
          />
        </div>
        <UserAuthForm />
      </div>
    </ContainerLayout>
  );
}
