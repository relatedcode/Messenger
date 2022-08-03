import Spinner from "components/Spinner";

export default function LoadingScreen() {
  return (
    <div className="h-screen w-screen flex items-center justify-center th-bg-bg">
      <Spinner className="h-6 w-6 th-color-for" />
    </div>
  );
}
