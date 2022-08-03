import { APP_NAME } from "config";
import { Helmet } from "react-helmet-async";

export default function NotFound() {
  return (
    <>
      <Helmet>
        <title>{APP_NAME}</title>
      </Helmet>
      <div className="min-h-screen pt-16 pb-12 flex flex-col">
        <main className="flex-grow flex flex-col justify-center max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex-shrink-0 flex justify-center">
            <a href="/" className="inline-flex">
              <span className="sr-only">{APP_NAME}</span>
              <img
                className="h-16 w-auto rounded"
                src={`${process.env.PUBLIC_URL}/logo.png`}
                alt="Logo"
              />
            </a>
          </div>
          <div className="py-16">
            <div className="text-center">
              <p className="text-sm font-semibold th-color-for uppercase tracking-wide">
                404 error
              </p>
              <h1 className="mt-2 text-4xl font-extrabold th-color-for tracking-tight sm:text-5xl">
                Page not found.
              </h1>
              <p className="mt-2 text-base th-color-for">
                Sorry, we couldn’t find the page you’re looking for.
              </p>
              <div className="mt-6">
                <a href="/" className="text-base font-medium th-color-for">
                  Go back home<span aria-hidden="true"> &rarr;</span>
                </a>
              </div>
            </div>
          </div>
        </main>
      </div>
    </>
  );
}
