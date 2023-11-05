import {FakeDashboardProvider} from "@/stories/FakeDashboardProvider";
import {Meta, StoryObj} from "@storybook/react";
import {subMonths} from "date-fns";
import React from "react";
import DashboardPage from "@/app/(pages)/dashboard/page";
import {Overview} from "@/components/dashboard-components/overview";

export default {
  title: 'Dashboard/Page',
  parameters: {
    nextjs: {
      appDirectory: true,
    },
  },
  component: DashboardPage,
  decorators: [
    (Story, context) => (
        <FakeDashboardProvider startDate={context.args.startDate} endDate={context.args.endDate}>
          <Story/>
        </FakeDashboardProvider>
    ),
  ],
} as Meta;

export const Month: StoryObj<typeof DashboardPage> = {
  args: {
    startDate: subMonths(new Date(), 1),
    endDate: new Date(),
  },
};

export const ThreeMonths: StoryObj<typeof Overview> = {
  args: {
    startDate: subMonths(new Date(), 3),
    endDate: new Date(),
  },
};

export const SixMonths: StoryObj<typeof Overview> = {
  args: {
    startDate: subMonths(new Date(), 6),
    endDate: new Date(),
  },
};

export const NineMonths: StoryObj<typeof Overview> = {
  args: {
    startDate: subMonths(new Date(), 9),
    endDate: new Date(),
  },
};

export const Year: StoryObj<typeof Overview> = {
  args: {
    startDate: subMonths(new Date(), 12),
    endDate: new Date(),
  },
};