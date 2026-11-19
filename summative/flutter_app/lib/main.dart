import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const InfrastructureDelayApp());
}

class InfrastructureDelayApp extends StatelessWidget {
  const InfrastructureDelayApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF222836);
    const cardColor = Color(0xFF2A3040);
    const accentColor = Color(0xFFC778DD);
    const textColor = Color(0xFFF5F5F5);
    const secondaryTextColor = Color(0xFFABB2BF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Infrastructure Delay Predictor',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgColor,
        primaryColor: accentColor,
        colorScheme: const ColorScheme.dark(
          primary: accentColor,
          surface: cardColor,
          secondary: accentColor,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF222836),
          hintStyle: const TextStyle(color: secondaryTextColor),
          labelStyle: const TextStyle(color: secondaryTextColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF49516A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: accentColor, width: 1.4),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
      home: const InfrastructureDelayHomePage(),
    );
  }
}

class InfrastructureDelayHomePage extends StatefulWidget {
  const InfrastructureDelayHomePage({super.key});

  @override
  State<InfrastructureDelayHomePage> createState() =>
      _InfrastructureDelayHomePageState();
}

class _InfrastructureDelayHomePageState
    extends State<InfrastructureDelayHomePage> {
  static const String baseUrl = 'https://infrastructure-delay-api.onrender.com';

  final _formKey = GlobalKey<FormState>();

  // Controllers for the 11 infrastructure variables
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _profFeesController = TextEditingController();
  final TextEditingController _constCostsController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final TextEditingController _contractorCountController =
      TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _natureController = TextEditingController();
  final TextEditingController _fundingController = TextEditingController();

  String _resultMessage = 'Prediction result will appear here.';
  bool _predictionIsError = false;
  bool _isPredicting = false;

  @override
  void dispose() {
    _costController.dispose();
    _profFeesController.dispose();
    _constCostsController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _contractorCountController.dispose();
    _provinceController.dispose();
    _deptController.dispose();
    _sectorController.dispose();
    _natureController.dispose();
    _fundingController.dispose();
    super.dispose();
  }

  Future<void> _predictDelay() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPredicting = true;
      _predictionIsError = false;
      _resultMessage = 'Predicting...';
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "cost": double.parse(_costController.text.trim()),
          "prof_fees": double.parse(_profFeesController.text.trim()),
          "const_costs": double.parse(_constCostsController.text.trim()),
          "lat": double.parse(_latController.text.trim()),
          "lon": double.parse(_lonController.text.trim()),
          "contractor_count": int.parse(_contractorCountController.text.trim()),
          "province": _provinceController.text.trim(),
          "dept": _deptController.text.trim(),
          "sector": _sectorController.text.trim(),
          "nature": _natureController.text.trim(),
          "funding": _fundingController.text.trim(),
        }),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prediction = decoded['predicted_delay_days'];
        setState(() {
          _predictionIsError = false;
          _resultMessage =
              'Predicted Delay: ${double.parse(prediction.toString()).toStringAsFixed(2)} days';
        });
      } else {
        setState(() {
          _predictionIsError = true;
          _resultMessage =
              'API Error: ${response.statusCode}\nCheck your input ranges.';
        });
      }
    } catch (e) {
      setState(() {
        _predictionIsError = true;
        _resultMessage = 'Connection Error: Could not reach the API.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPredicting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: width < 600 ? 16 : 28,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HeaderSection(),
                  const SizedBox(height: 28),
                  _buildPredictionCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionCard() {
    return _SectionCard(
      title: '#predict-delay',
      subtitle: 'Enter the project details below to estimate the delay days using the deployed regression model.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              _costController,
              'Estimated Total Cost (R)',
              'e.g. 5000000',
              isNumber: true,
            ),
            _buildTextField(
              _profFeesController,
              'Professional Fees (R)',
              'e.g. 500000',
              isNumber: true,
            ),
            _buildTextField(
              _constCostsController,
              'Construction Costs (R)',
              'e.g. 4500000',
              isNumber: true,
            ),
            _buildTextField(
              _latController,
              'Latitude',
              'e.g. -30.5',
              isNumber: true,
            ),
            _buildTextField(
              _lonController,
              'Longitude',
              'e.g. 30.4',
              isNumber: true,
            ),
            _buildTextField(
              _contractorCountController,
              'Contractor Project Count',
              'e.g. 5',
              isNumber: true,
            ),
            _buildTextField(
              _provinceController,
              'Province',
              'e.g. KwaZulu-Natal',
            ),
            _buildTextField(_deptController, 'Department', 'e.g. Education'),
            _buildTextField(_sectorController, 'Sector', 'e.g. Education'),
            _buildTextField(
              _natureController,
              'Nature of Investment',
              'e.g. Upgrading',
            ),
            _buildTextField(
              _fundingController,
              'Primary Funding Source',
              'e.g. Equitable Share',
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isPredicting ? null : _predictDelay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC778DD),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isPredicting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Predict',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 22),
            _ResultPanel(
              title: 'Prediction output',
              message: _resultMessage,
              isError: _predictionIsError,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true, signed: true)
            : TextInputType.text,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            const Text(
              'InfraDelay',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Container(width: 120, height: 2, color: const Color(0xFFC778DD)),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Infrastructure project delay prediction.',
          style: TextStyle(fontSize: 16, color: Color(0xFFABB2BF), height: 1.7),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A3040),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFC778DD).withOpacity(0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFC778DD), thickness: 0.7),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFABB2BF),
              height: 1.7,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final String title;
  final String message;
  final bool isError;

  const _ResultPanel({
    required this.title,
    required this.message,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isError
        ? Colors.redAccent.withOpacity(0.7)
        : const Color(0xFFC778DD).withOpacity(0.75);

    final bgColor = isError ? const Color(0xFF3A2430) : const Color(0xFF222836);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              color: isError ? Colors.red[200] : const Color(0xFFABB2BF),
              height: 1.7,
              fontSize: 14.5,
            ),
          ),
        ],
      ),
    );
  }
}
