import 'package:flutter/material.dart';

class LandFill extends StatefulWidget {
  const LandFill({Key? key}) : super(key: key);

  @override
  State<LandFill> createState() => _LandFillState();
}

class _LandFillState extends State<LandFill> {
  TextEditingController adharController = TextEditingController();
  TextEditingController houseNameController = TextEditingController();
  TextEditingController villageController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();

  bool isFormValid = false;
  String age = '';

  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFF8E2),
      appBar: AppBar(
        backgroundColor: Color(0xffC4AB62), // Set app bar background color
        title: Text('Fill Land Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SVG image
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white, // Border color
                    width: 2.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(12.0), // Border radius
                ),
                // Add your SVG image here
                child: Image.asset('assets/filllin.png'),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    keyboardType: TextInputType.datetime,
                    controller: TextEditingController(
                      text: selectedDate == null
                          ? ''
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Date of Birth *:',
                      hintText: 'Select Date of Birth',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Age: $age'), // Display calculated age
              SizedBox(height: 20),
              Text('Adhar Number *:'),
              TextFormField(
                controller: adharController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter Adhar Number',
                ),
                onChanged: (_) => validateForm(),
              ),
              SizedBox(height: 20),
              Text('House Name *:'),
              TextFormField(
                controller: houseNameController,
                decoration: InputDecoration(
                  hintText: 'Enter House Name',
                ),
                onChanged: (_) => validateForm(),
              ),
              SizedBox(height: 20),
              Text('Village *:'),
              TextFormField(
                controller: villageController,
                decoration: InputDecoration(
                  hintText: 'Enter Village',
                ),
                onChanged: (_) => validateForm(),
              ),
              SizedBox(height: 20),
              Text('City *:'),
              TextFormField(
                controller: cityController,
                decoration: InputDecoration(
                  hintText: 'Enter City',
                ),
                onChanged: (_) => validateForm(),
              ),
              SizedBox(height: 20),
              Text('State *:'),
              TextFormField(
                controller: stateController,
                decoration: InputDecoration(
                  hintText: 'Enter State',
                ),
                onChanged: (_) => validateForm(),
              ),
              SizedBox(height: 20),
              Text('Pincode *:'),
              TextFormField(
                controller: pincodeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter Pincode',
                ),
                onChanged: (_) => validateForm(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid ? Colors.black : Colors.grey.shade600,
                ),
                onPressed: isFormValid
                    ? () {
                  if (!isFormValid) {
                    _scrollToFirstUnfilledField(context);
                  } else {
                    // Perform action on button click
                  }
                }
                    : null,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        calculateAge();
        validateForm();
      });
    }
  }

  void _scrollToFirstUnfilledField(BuildContext context) {
    // Find the first unfilled field and scroll to it
    List<TextEditingController> controllers = [
      adharController,
      houseNameController,
      villageController,
      cityController,
      stateController,
      pincodeController,
    ];

    for (TextEditingController controller in controllers) {
      if (controller.text.isEmpty) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        Scrollable.ensureVisible(context, alignment: 0.5, duration: Duration(milliseconds: 500));
        break;
      }
    }
  }

  void validateForm() {
    setState(() {
      isFormValid = selectedDate != null &&
          adharController.text.length == 12 &&
          houseNameController.text.isNotEmpty &&
          villageController.text.isNotEmpty &&
          cityController.text.isNotEmpty &&
          stateController.text.isNotEmpty &&
          pincodeController.text.isNotEmpty &&
          int.tryParse(pincodeController.text) != null; // Check if pincode is a number
    });
  }

  void calculateAge() {
    if (selectedDate != null) {
      DateTime now = DateTime.now();
      int years = now.year - selectedDate!.year;
      int months = now.month - selectedDate!.month;
      int days = now.day - selectedDate!.day;
      if (months < 0 || (months == 0 && days < 0)) {
        years--;
      }
      setState(() {
        age = years.toString();
      });
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: LandFill(),
  ));
}
