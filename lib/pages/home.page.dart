import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String sportName;
  HomePage(this.sportName);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, List<dynamic>> matchesByLeague = {};
  bool isLoading = true;
  String selectedLeague = 'All Leagues';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getMatchesData();
  }

  void getMatchesData() async {
    var headers = {
      'x-rapidapi-key': 'b37491a95d1ba3b6b65514cf3be56124',
      'x-rapidapi-host': 'v3.football.api-sports.io',
    };

    var queryParams = {
      'date': selectedDate.toIso8601String().split('T')[0],
    };

    var uri = Uri.https('v3.football.api-sports.io', '/fixtures', queryParams);

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          if (data.containsKey('response')) {
            List<dynamic> matches = data['response'];
            if (selectedLeague != 'All Leagues') {
              matches = matches.where((match) => match['league']['name'] == selectedLeague).toList();
            }
            matchesByLeague = {};
            for (var match in matches) {
              String leagueName = match['league']['name'];
              if (matchesByLeague.containsKey(leagueName)) {
                matchesByLeague[leagueName]!.add(match);
              } else {
                matchesByLeague[leagueName] = [match];
              }
            }
          } else {
            print("La propriété 'response' n'est pas présente dans la réponse JSON.");
          }
          isLoading = false;
        });
      } else {
        print("Erreur de réponse de l'API: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des données: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matches - ${widget.sportName}', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedLeague,
                    items: <String>['All Leagues', 'Premier League', 'La Liga', 'Bundesliga']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900])),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedLeague = newValue!;
                        isLoading = true;
                        getMatchesData();
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2025),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                        isLoading = true;
                        getMatchesData();
                      });
                    }
                  },
                  child: Text('Select Date'),
                ),
              ],
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : matchesByLeague.isEmpty
              ? Center(child: Text('Aucun match trouvé.'))
              : Expanded(
            child: ListView.builder(
              itemCount: matchesByLeague.keys.length,
              itemBuilder: (context, index) {
                String leagueName = matchesByLeague.keys.elementAt(index);
                List<dynamic> leagueMatches = matchesByLeague[leagueName]!;
                return ExpansionTile(
                  title: Text(leagueName),
                  backgroundColor: Colors.white70,
                  children: leagueMatches.map((match) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Pays: ${match['league']['country']}', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text('Ligue: ${match['league']['name']}', style: TextStyle(fontStyle: FontStyle.italic)),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${match['teams']['home']['name']}'),
                                    match['teams']['home']['logo'] != null
                                        ? Image.network(match['teams']['home']['logo'], height: 50, width: 50)
                                        : Icon(Icons.image, size: 50),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${match['teams']['away']['name']}'),
                                    match['teams']['away']['logo'] != null
                                        ? Image.network(match['teams']['away']['logo'], height: 50, width: 50)
                                        : Icon(Icons.image, size: 50),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            if (match['fixture']['status']['short'] != 'NS')
                              Text('Score: ${match['goals']['home']} - ${match['goals']['away']}', style: TextStyle(fontSize: 15)),
                            SizedBox(height: 8),
                            Text('Date: ${match['fixture']['date']}', style: TextStyle(fontSize: 10)),
                            SizedBox(height: 8),
                            Text('Statut: ${match['fixture']['status']['long']}', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
