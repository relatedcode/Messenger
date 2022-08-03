module.exports = {
  presets: ['module:metro-react-native-babel-preset', 'babel-preset-expo'],
  plugins: [
    'react-native-reanimated/plugin',
    [
      'module-resolver',
      {
        alias: {
          '@': './',
        },
      },
    ],
  ],
};
