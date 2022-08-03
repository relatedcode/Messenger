const Style = (props: any) => {
  return (
    <style
      dangerouslySetInnerHTML={{
        __html: props.css,
      }}
    />
  );
};

export default Style;
