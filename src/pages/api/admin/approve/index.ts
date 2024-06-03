import type { APIRoute } from "astro";
import { supabase } from "@/lib/supabase";

export const POST: APIRoute = async ({ request, redirect }) => {
  const formData = await request.formData();
  const doctor_id = formData.get("doctor_id");
  const approved = formData.get("approved");

  if (!doctor_id) {
    return new Response("Doctor are required", { status: 400 });
  }

  const { error } = await supabase
    .from("doctors")
    .update({ approved: approved })
    .eq("user_id", doctor_id)
    .single();

  if (error) {
    return new Response(error.message, { status: 500 });
  }

  return redirect("/admin/dashboard");
};
