// IntraDayScreen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../HomePage.dart';
import 'IntraDayModel.dart';

class IntraDayScreen extends StatefulWidget {
  const IntraDayScreen({Key? key}) : super(key: key);

  @override
  State<IntraDayScreen> createState() => _IntraDayScreenState();
}

class _IntraDayScreenState extends State<IntraDayScreen> {
  final List<String> dropdownItems = ['All', 'Achieved', 'Active', 'SL Hit'];
  String? _selectedDropdownItem;
  String? _searchQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: const Text(
              "Intraday",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 50,
                    child: TextFormField(
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_outlined),
                        labelText: 'Search by Stocks..',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    child: DropdownButton<String>(
                      value: _selectedDropdownItem,
                      onChanged: (value) {
                        setState(() {
                          _selectedDropdownItem = value;
                        });
                      },
                      items: dropdownItems
                          .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ))
                          .toList(),
                      hint: const Text('All', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
              color: Colors.deepPurpleAccent,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Text(
                      "Stock",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Target",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "SL",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Remarks",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: IntraDayList(
                  searchQuery: _searchQuery,
                  statusFilter: _selectedDropdownItem),
            ),
          ],
        ),
      ),
    );
  }
}

// IntraDayList.dart

// IntraDayList.dart

class IntraDayList extends StatelessWidget {
  final String? searchQuery;
  final String? statusFilter;

  const IntraDayList({Key? key, this.searchQuery, this.statusFilter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('Stocks')
        .where('category', isEqualTo: 'IntraDay')
        .where('stockName', isGreaterThanOrEqualTo: searchQuery ?? '')
        .where('stockName',
            isLessThan: searchQuery != null ? '${searchQuery!}z' : 'z');

    // Apply status filter if selected
    if (statusFilter != null && statusFilter != 'All') {
      query = query.where('status', isEqualTo: statusFilter);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
        }

        final data = snapshot.data?.docs
            .map((doc) => IntraDayModel.fromSnapshot(doc))
            .toList();

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: data!.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final item = data[index];
            final formattedDate =
                DateFormat('dd/MM/yyyy').format(item.date.toDate());

            var statusColor = item.status == 'SL Hit' ? Colors.red : null;
            var slColor = item.status == 'SL Hit' ? Colors.red : null;

            if (item.status == 'Achieved' || item.status == 'Active') {
              statusColor = Colors.green;
              slColor = Colors.green;
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        item.stockName,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        'CMP: ${item.cmp}',
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    item.target,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.sl,
                    style: TextStyle(fontSize: 14, color: slColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        item.remark,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        item.status,
                        style: TextStyle(fontSize: 14, color: statusColor),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
