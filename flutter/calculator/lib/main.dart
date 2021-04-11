import 'package:calculator/res/colors.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MyApp());
  double input;
  double previousInput;
  String symbol;
}

void onItemClicked(String value) {
  print('On Click $value');

  switch (value) {
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      onNewDigit(value);
      break;
    case '+':
    case '-':
    case '/':
    case '*':
      onNewSymbol(value);
      break;
    case '=':
      onEquals();
  }

  // redessine l'interface
  setState(() {});
}

void setState(Null Function() param0) {}

void onNewDigit(String digit) {
  // TODO
}

void onNewSymbol(String digit) {
  // TODO
}

void onEquals() {
  // TODO
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: ValueNotifier(GraphQLClient(
          link: HttpLink(
              'https://snowy-firefly.eu-central-1.aws.cloud.dgraph.io/graphql'),
          cache: GraphQLCache())),
      child: MaterialApp(
        title: 'Pokedex',
        theme: ThemeData(
          primaryColor: AppColors.inputContainerBackground,
          accentColor: AppColors.displayContainerBackground,
          primaryColorBrightness: Brightness.light,
        ),
        home: Pokedex(),
      ),
    );
  }
}

class Pokedex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(document: gql('''
query MyQuery {
 queryPokemon {
   id
   name
 }
}
       ''')),
        builder: (QueryResult result, {Refetch refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return Text('Error');
          } else if (result.isLoading) {
            return Text('Loading');
          }

          List pokemons = (result.data as Map)['queryPokemon'] as List;

          return Scaffold(
            body: ListView.builder(
              itemBuilder: (BuildContext context, int position) {
                var pokemon = pokemons[position];

                return GraphQLConsumer(
                  builder: (GraphQLClient client) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Image.network(pokemon['imgUrl']),
                        backgroundColor: AppColors.white,
                      ),
                      title: Text(pokemon['name']),
                    );
                  },
                );
              },
              itemCount: pokemons.length,
            ),
          );
        });
  }
}

class InputButton extends StatelessWidget {
  final label;
  final onTap;

  InputButton({this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(label),
      child: Ink(
        height: double.infinity,
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.white, width: 0.5),
            color: AppColors.inputContainerBackground),
        child: Center(
          child: Text(
            label,
          ),
        ),
      ),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  get input => null;

  static const List<List<String>> grid = <List<String>>[
    <String>["7", "8", "9", "-"],
    <String>["4", "5", "6", "*"],
    <String>["1", "2", "3", "/"],
    <String>["0", ".", "=", "+"],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTextStyle(
        style: TextStyle(color: AppColors.white, fontSize: 22.0),
        child: Column(
          children: [
            Flexible(
              flex: 2,
              child: Container(
                color: AppColors.displayContainerBackground,
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsets.all(22.0),
                child: Text(input?.toString() ?? "0"),
              ),
            ),
            Flexible(
              flex: 8,

              // column = vertical
              child: Column(
                //On itère chaque cellule pour chaque nouvelle ligne
                children: grid.map((List<String> line) {
                  return Expanded(
                    child: Row(
                        children: line
                            .map(
                              (String cell) => Expanded(
                                child: InputButton(
                                  label: cell,
                                  onTap: onItemClicked,
                                ),
                              ),
                            )
                            .toList(growable: false)),
                  );
                }).toList(growable: false),
              ),
            )
          ],
        ),
      ),
    );
  }
}
