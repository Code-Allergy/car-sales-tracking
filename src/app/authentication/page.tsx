"use client";

import Image from "next/image";
import * as React from "react";
import ContainerLayout from "@/components/container-layout";
import dynamic from "next/dynamic";
import DemoCard from "@/components/demo/DemoCard";

const UserAuthForm = dynamic(() => import("./components/user-auth-form"));

export default function AuthenticationPage() {
  const random = Math.floor(Math.random() * 4) + 1;
  return (
    <ContainerLayout>
      <div className="container relative flex flex-col items-center justify-center h-[800px] md:grid lg:max-w-none lg:grid-cols-2 lg:px-0 ">
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
        <div>
          <DemoCard/>
          <UserAuthForm />
        </div>
      </div>
    </ContainerLayout>
  );
}
