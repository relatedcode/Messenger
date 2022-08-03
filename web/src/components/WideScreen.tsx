import { APP_NAME } from "config";
import React, { useEffect, useState } from "react";

export default function SmallScreen({
  children,
}: {
  children: React.ReactNode;
}) {
  const size = useWindowSize();

  if (!size) return null;
  if (size.width < 770)
    return (
      <div className="h-screen w-screen items-center justify-center flex">
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
              <h1 className="mt-2 text-4xl font-extrabold th-color-for tracking-tight">
                Please use a larger screen.
              </h1>
              <p className="mt-2 text-base th-color-for">
                Sorry, this page is not yet optimized for mobile.
              </p>
            </div>
          </div>
        </main>
      </div>
    );
  return <>{children}</>;
}

function useWindowSize() {
  const [windowSize, setWindowSize] = useState<any>({
    width: undefined,
    height: undefined,
  });
  useEffect(() => {
    // Handler to call on window resize
    function handleResize() {
      // Set window width/height to state
      setWindowSize({
        width: window.innerWidth,
        height: window.innerHeight,
      });
    }
    // Add event listener
    window.addEventListener("resize", handleResize);
    // Call handler right away so state gets updated with initial window size
    handleResize();
    // Remove event listener on cleanup
    return () => window.removeEventListener("resize", handleResize);
  }, []); // Empty array ensures that effect is only run on mount
  return windowSize;
}
