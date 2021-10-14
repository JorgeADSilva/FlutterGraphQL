import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const productsGraphQL = """ 
  query products {
    products(first: 10, channel: "default-channel"){
      edges{
        node{
          id
          name
          description
          pricing {
            onSale
          }
          thumbnail {
            url
          }
        }
      }
    }
  }
""";
void main() {
  final HttpLink httpLink = HttpLink("https://demo.saleor.io/graphql/");

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(link: httpLink, cache: GraphQLCache(store: InMemoryStore())),
  );

  var app = GraphQLProvider(client: client, child: MyApp());
  runApp(app);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("GraphQL Prototype"),
          ),
          body: Query(
            options: QueryOptions(
              document: gql(productsGraphQL),
            ),
            builder: (QueryResult result, {fetchMore, refetch}) {
              if (result.hasException) {
                print(result.exception.toString());
                return Text(result.exception.toString());
              }
              if (result.isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final productList = result.data!['products']['edges'];
              print(result.data.toString());

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Products",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Expanded(
                      child: GridView.builder(
                          itemCount: productList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 2,
                                  crossAxisSpacing: 2,
                                  childAspectRatio: 0.75),
                          itemBuilder: (_, index) {
                            var product = productList[index]['node'];
                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.0),
                                  width: 180,
                                  height: 180,
                                  child: Image.network(
                                      product['thumbnail']['url']),
                                ),
                                Text(product['name']),
                                Text(
                                  product['pricing']['onSale'] ? "OnSale" : "",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                              ],
                            );
                          }))
                ],
              );
            },
          )),
    );
  }
}
