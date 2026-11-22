import * as React from "react";
import { Input as InputPrimitive } from "@base-ui/react/input";
import { cn } from "cn";

function Input({ className, type, ...props }: React.ComponentProps<"input">) {
  return (
    <InputPrimitive
      type={type}
      data-slot="input"
      className={cn(
        "min-h-[48px] w-full min-w-0 rounded-2xl border border-border bg-field px-4 py-2 text-sm text-foreground transition-colors outline-none file:inline-flex file:h-8 file:cursor-pointer file:items-center file:rounded-full file:border-0 file:bg-accent file:px-3 file:text-xs file:font-semibold file:text-accent-foreground placeholder:text-muted-foreground focus-visible:border-[1.6px] focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/25 disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20",
        className,
      )}
      {...props}
    />
  );
}

export { Input };
