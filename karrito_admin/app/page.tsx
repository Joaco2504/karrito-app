import { redirect } from "next/navigation";
import { AdminShell } from "@/components/admin/admin-shell";
import { requireAdminSession } from "@/lib/auth/admin";
import { getAdminDashboardData } from "@/lib/data/dashboard";

export const dynamic = "force-dynamic";

export default async function HomePage() {
  const session = await requireAdminSession();

  if (!session.authorized) {
    if (session.reason === "forbidden") {
      redirect("/login?error=acceso_denegado");
    }
    redirect("/login");
  }

  const data = await getAdminDashboardData();

  return (
    <AdminShell
      adminEmail={session.email}
      adminUserId={session.userId}
      data={data}
    />
  );
}
