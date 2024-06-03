import type { APIRoute } from "astro";
import { supabase } from "@/lib/supabase";

export const POST: APIRoute = async ({ request, redirect }) => {
  const formData = await request.formData();
  const appointment_id = formData.get("appointment_id")?.toString();
  const patient_id = formData.get("patient_id")?.toString();
  const doctor_id = formData.get("doctor_id")?.toString();
  const time = formData.get("time")?.toString();
  const purpose = formData.get("purpose")?.toString();

  if (!patient_id || !doctor_id) {
    return new Response("Patient and Doctor are required", { status: 400 });
  }

  const { error } = await supabase
    .from("appointments")
    .update({ patient_id, doctor_id, time, purpose })
    .eq("id", appointment_id)
    .single();

  if (error) {
    return new Response(error.message, { status: 500 });
  }

  return redirect("/patient/dashboard");
};
