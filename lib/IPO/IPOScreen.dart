import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'IPOModel.dart';

class IPOScreen extends StatefulWidget {
  const IPOScreen({Key? key}) : super(key: key);

  @override
  State<IPOScreen> createState() => _IPOScreenState();
}

class _IPOScreenState extends State<IPOScreen> {
  List<IPOModel>? ipoList;
  List<IPOModel>? filteredIpoList;

  // Track the selected state for each filter
  bool isAllSelected = true;
  bool isCurrentSelected = false;
  bool isUpcomingSelected = false;

  @override
  void initState() {
    super.initState();
    fetchIPOs();
  }

  Future<void> fetchIPOs() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('IPO').get();

      ipoList =
          querySnapshot.docs.map((doc) => IPOModel.fromSnapshot(doc)).toList();
      filteredIpoList = ipoList;
      setState(() {});
    } catch (e) {
      print("Error fetching IPOs: $e");
    }
  }

  void searchIPOs(String query) {
    setState(() {
      filteredIpoList = ipoList
          ?.where((ipo) =>
              ipo.stockName.toLowerCase().contains(query.toLowerCase()) &&
              (isAllSelected ||
                  (isCurrentSelected && ipo.status == 'Current') ||
                  (isUpcomingSelected && ipo.status == 'Upcoming')))
          .toList();
    });
  }

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
              "IPO",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
          ),
        ),
      ),
      body: ipoList == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: TextFormField(
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: const Icon(Icons.search_outlined),
                        labelText: 'Search by IPO ...',
                        labelStyle: const TextStyle(fontSize: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: searchIPOs,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFilterContainer('All', isAllSelected,
                          () => _handleFilterSelection('All')),
                      _buildFilterContainer('Current', isCurrentSelected,
                          () => _handleFilterSelection('Current')),
                      _buildFilterContainer('Upcoming', isUpcomingSelected,
                          () => _handleFilterSelection('Upcoming')),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 60,
                      dataRowMaxHeight: 62,
                      horizontalMargin: 8,
                      columnSpacing: 0,
                      columns: [
                        _buildDataColumn('Name', 210),
                        _buildDataColumn('Lot', 80),
                        _buildDataColumn('Price', 100),
                        _buildDataColumn('OpenOn', 120),
                        _buildDataColumn('CloseOn', 120),
                        _buildDataColumn('Remarks', 150),
                      ],
                      rows: filteredIpoList
                              ?.map((ipo) => _buildDataRow(ipo))
                              .toList() ??
                          [],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  DataColumn _buildDataColumn(String label, double width) {
    return DataColumn(
      //using container
      label: Container(
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          border: Border.all(
            color: Colors.deepPurpleAccent,
          ),
        ),
        // Text k baare m sab aagya isme
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(IPOModel ipo) {
    return DataRow(
      cells: [
        _buildDataCell(ipo.stockName, 210),
        _buildDataCell(ipo.lot.toString(), 80),
        _buildDataCell(ipo.price.toString(), 100),
        _buildDataCell(ipo.openingDate, 120),
        _buildDataCell(ipo.closingDate, 120),
        _buildDataCell(ipo.remark, 150),
      ],
    );
  }

  DataCell _buildDataCell(String data, double width) {
    return DataCell(
      Container(
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white // Light theme background color
              : Colors.black, // Dark theme background color
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: Text(
          data,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black // Light theme text color
                : Colors.white, // Dark theme text color
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterContainer(
      String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 80,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurpleAccent : Colors.white,
          borderRadius: BorderRadius.circular(0),
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _handleFilterSelection(String filter) {
    setState(() {
      // Reset all selections
      isAllSelected = false;
      isCurrentSelected = false;
      isUpcomingSelected = false;

      // Set the selected filter
      if (filter == 'All') {
        isAllSelected = true;
        filteredIpoList = ipoList;
      } else if (filter == 'Current') {
        isCurrentSelected = true;
        filteredIpoList =
            ipoList?.where((ipo) => ipo.status == 'Current').toList();
      } else if (filter == 'Upcoming') {
        isUpcomingSelected = true;
        filteredIpoList =
            ipoList?.where((ipo) => ipo.status == 'Upcoming').toList();
      }
    });
  }
}
