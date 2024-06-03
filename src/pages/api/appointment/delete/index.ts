import type { APIRoute } from "astro";
import { supabase } from "@/lib/supabase";

export const POST: APIRoute = async ({ request, redirect }) => {
  const formData = await request.formData();
  const appointment_id = formData.get("appointment_id")?.toString();

  const { data, error } = await supabase
    .from("appointments")
    .delete()
    .eq("id", appointment_id);

  if (error) {
    return new Response(error.message, { status: 500 });
  }

  return redirect("/patient/dashboard");
};
