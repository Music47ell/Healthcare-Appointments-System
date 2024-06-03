import type { APIRoute } from "astro";
import { supabase } from "@/lib/supabase";

export const POST: APIRoute = async ({ request, redirect }) => {
  const formData = await request.formData();
  const name = formData.get("name")?.toString();
  const dob = formData.get("dob")?.toString();
  const gender = formData.get("gender")?.toString();
  const email = formData.get("email")?.toString();
  const password = formData.get("password")?.toString();

  if (!email || !password) {
    return new Response("Email and password are required", { status: 400 });
  }

  const {
    data: { user },
    error,
  } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        name,
        dob,
        gender,
        role: "patient",
      },
    },
  });

  if (error) {
    return new Response(error.message, { status: 500 });
  }

  return redirect("/");
};
