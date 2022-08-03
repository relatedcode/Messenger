import {useAuth} from '@/contexts/AuthContext';
import {showAlert} from '@/lib/alert';
import {globalStyles} from '@/styles/styles';
import {useFormik} from 'formik';
import {SafeAreaView, View} from 'react-native';
import {Button, TextInput, Title} from 'react-native-paper';

export default function Login() {
  const {login} = useAuth();

  const {handleSubmit, handleChange, values, isSubmitting} = useFormik({
    initialValues: {
      email: '',
      password: '',
    },
    enableReinitialize: true,
    onSubmit: async val => {
      try {
        if (!val.email) {
          showAlert('Email must be set.');
          return;
        }
        if (!val.password) {
          showAlert('Password must be set.');
          return;
        }

        await login(val.email, val.password);
      } catch (err) {
        // showAlert('Invalid password.');
        showAlert(err.message);
      }
    },
  });

  return (
    <SafeAreaView
      style={{padding: 30, marginTop: 'auto', marginBottom: 'auto'}}>
      <Title style={{fontWeight: '600', fontSize: 30}}>Messenger</Title>
      <View style={{flexDirection: 'column'}}>
        <TextInput
          value={values.email}
          onChangeText={handleChange('email')}
          placeholder="Email"
          dense
          label="Email"
          keyboardType="email-address"
          autoCapitalize="none"
          autoComplete="email"
          style={[globalStyles.input, {marginTop: 20}]}
        />
        <TextInput
          value={values.password}
          onChangeText={handleChange('password')}
          placeholder="Password"
          autoComplete="password"
          autoCapitalize="none"
          label="Password"
          dense
          secureTextEntry
          style={[globalStyles.input, {marginTop: 20}]}
        />
        <Button
          mode="contained"
          loading={isSubmitting}
          disabled={isSubmitting}
          style={{marginTop: 20}}
          onPress={handleSubmit}>
          Sign In
        </Button>
      </View>
    </SafeAreaView>
  );
}
