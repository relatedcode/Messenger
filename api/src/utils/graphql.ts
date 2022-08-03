import { GraphQLClient } from "graphql-request";
import { GQL_SERVER_URL } from "lib/config";

export default function graphQLClient(token?: string) {
  return new GraphQLClient(`${GQL_SERVER_URL}/graphql`, {
    headers: {
      ...(token && { authorization: `Bearer ${token}` }),
    },
  });
}
