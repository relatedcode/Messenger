import AuthButton from "components/authentication/AuthButton";
import TextField from "components/TextField";
import { APP_NAME, FAKE_EMAIL } from "config";
import { Formik } from "formik";
import useAuth from "hooks/useAuth";
import React from "react";
import { Helmet } from "react-helmet-async";
import toast from "react-hot-toast";
import { Link, useNavigate } from "react-router-dom";

function Header() {
  return (
    <header className="w-full py-8 grid grid-cols-3">
      <div />
      <div className="flex items-center justify-center">
        <img
          src={`${process.env.PUBLIC_URL}/logo.png`}
          alt="logo"
          className="h-16 w-auto rounded-md"
        />
      </div>
      <div className="flex text-sm flex-col justify-center items-end mr-6">
        <div className="th-color-for">Don&apos;t have an account yet?</div>
        <Link
          to="/authentication/register"
          className="font-semibold th-color-blue"
        >
          Create an account
        </Link>
      </div>
    </header>
  );
}

export default function Login() {
  const navigate = useNavigate();
  const { login } = useAuth();

  return (
    <>
      <Helmet>
        <title>{APP_NAME}</title>
      </Helmet>
      <Header />
      <div className="max-w-2xl flex flex-col items-center mx-auto h-full">
        <h1 className="font-extrabold text-5xl mb-2 th-color-for">Sign In</h1>
        <Formik
          initialValues={{
            email: "",
            password: "",
          }}
          onSubmit={async ({ email, password }, { setSubmitting }) => {
            setSubmitting(true);
            try {
              let emailPayload = email;
              let passwordPayload = password;
              if (FAKE_EMAIL && !email.includes("@") && !password) {
                emailPayload = `${email}@${email}.com`;
                passwordPayload = `${email}111`;
              }
              await login(emailPayload, passwordPayload);
              navigate("/dashboard");
            } catch (err: any) {
              toast.error(err.message);
            }
            setSubmitting(false);
          }}
        >
          {({ values, handleChange, isSubmitting, handleSubmit }) => (
            <form className="max-w-md w-full mt-10" onSubmit={handleSubmit}>
              <div className="w-full space-y-5">
                <TextField
                  value={values.email}
                  handleChange={handleChange}
                  type={FAKE_EMAIL ? "text" : "email"}
                  required
                  label="Email address"
                  name="email"
                  autoComplete="email"
                  placeholder="name@email.com"
                />
                <TextField
                  value={values.password}
                  handleChange={handleChange}
                  type="password"
                  label="Password"
                  name="password"
                  required={!FAKE_EMAIL}
                  autoComplete="current-password"
                  placeholder="Your password"
                />
                <div className="pt-4">
                  <AuthButton text="Sign in" isSubmitting={isSubmitting} />
                </div>
              </div>
            </form>
          )}
        </Formik>
      </div>
    </>
  );
}
