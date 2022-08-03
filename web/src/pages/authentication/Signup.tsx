import AuthButton from "components/authentication/AuthButton";
import TextField from "components/TextField";
import { APP_NAME, FAKE_EMAIL } from "config";
import { Formik } from "formik";
import useAuth from "hooks/useAuth";
import { Helmet } from "react-helmet-async";
import toast from "react-hot-toast";
import { Link, useNavigate } from "react-router-dom";
import { postData } from "utils/api-helpers";

const capitalize = (str: string) => str.charAt(0).toUpperCase() + str.slice(1);

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
        <div className="th-color-for">Already have an account?</div>
        <Link
          to="/authentication/login"
          className="font-semibold th-color-blue"
        >
          Sign in
        </Link>
      </div>
    </header>
  );
}

export default function Signup() {
  const navigate = useNavigate();
  const { login } = useAuth();

  return (
    <>
      <Helmet>
        <title>{APP_NAME}</title>
      </Helmet>
      <Header />
      <div className="max-w-2xl flex flex-col items-center mx-auto">
        <h1 className="font-extrabold text-5xl mb-2 th-color-for">
          {`Sign up to ${APP_NAME}`}
        </h1>
        <Formik
          initialValues={{
            name: "",
            email: "",
            password: "",
          }}
          onSubmit={async ({ email, password, name }, { setSubmitting }) => {
            setSubmitting(true);
            try {
              let emailPayload = email;
              let passwordPayload = password;
              if (FAKE_EMAIL && !email.includes("@") && !password) {
                emailPayload = `${email}@${email}.com`;
                passwordPayload = `${email}111`;
              }
              await postData("/users", {
                name,
                email: emailPayload,
                password: passwordPayload,
              });
              await login(emailPayload, passwordPayload);
              navigate("/dashboard");
            } catch (err: any) {
              toast.error(err.message);
            }
            setSubmitting(false);
          }}
        >
          {({
            values,
            handleChange,
            isSubmitting,
            handleSubmit,
            setFieldValue,
          }) => (
            <form className="max-w-md w-full mt-10" onSubmit={handleSubmit}>
              <div className="w-full space-y-5">
                <TextField
                  value={values.name}
                  handleChange={(e: any) =>
                    setFieldValue("name", capitalize(e.target.value))
                  }
                  label="Full name"
                  name="name"
                  required
                  autoComplete="name"
                  placeholder="James Whisler"
                />
                <TextField
                  value={values.email}
                  handleChange={handleChange}
                  type={FAKE_EMAIL ? "text" : "email"}
                  label="Email address"
                  name="email"
                  required
                  autoComplete="email"
                  placeholder="name@work-email.com"
                />
                <TextField
                  type="password"
                  value={values.password}
                  handleChange={handleChange}
                  label="Password"
                  name="password"
                  required={!FAKE_EMAIL}
                  autoComplete="new-password"
                  placeholder="Your password"
                />
                <div className="pt-4">
                  <AuthButton
                    text="Create my account"
                    isSubmitting={isSubmitting}
                  />
                </div>
              </div>
            </form>
          )}
        </Formik>
      </div>
    </>
  );
}
