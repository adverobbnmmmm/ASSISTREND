import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart'; // ✅ for date formatting
import 'gamification_service.dart';

class GamificationFormPage extends StatefulWidget {
  const GamificationFormPage({super.key});

  @override
  State<GamificationFormPage> createState() => _GamificationFormPageState();
}

class _GamificationFormPageState extends State<GamificationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedGender;
  String? _profileImagePath;
  DateTime? _dob;
  String? _audioPath;
  List<int> _selectedInterestIds = [];
  String? _selectedEmoji;

  List<String> _emptyFields = [];
  List<Map<String, dynamic>> _interestList = [];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final profile = await GamificationService().getProfile();
    if (profile != null) {
      setState(() {
        _emptyFields = List<String>.from(profile['empty_fields'] ?? []);
        _interestList = List<Map<String, dynamic>>.from(profile['interest_list'] ?? []);

        // Prefill common fields if available
        _aboutController.text = profile['about'] ?? _aboutController.text;
        _locationController.text = profile['location'] ?? _locationController.text;
        _selectedGender = profile['gender'] ?? _selectedGender;
        _selectedEmoji = profile['emoji'] ?? _selectedEmoji;

        // parse dob if present (expecting "YYYY-MM-DD" or ISO)
        try {
          final dobString = profile['dob'];
          if (dobString != null && dobString.toString().isNotEmpty) {
            _dob = DateTime.parse(dobString.toString());
          }
        } catch (e) {
          // ignore parse errors and leave _dob null
        }

        // pre-select interests if backend returns them (list of ints)
        final incomingInterestIds = profile['interest_ids'];
        if (incomingInterestIds is List) {
          _selectedInterestIds = incomingInterestIds.whereType<int>().toList();
        } else if (profile['interest_list'] != null && profile['interest_list'] is List) {
          // sometimes interest_list contains selected flags; try to extract ids that have 'selected'
          try {
            _selectedInterestIds = (profile['interest_list'] as List)
                .whereType<Map>()
                .where((m) => m['selected'] == true)
                .map<int>((m) => (m['id'] as int))
                .toList();
          } catch (_) {
            // ignore
          }
        }
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) setState(() => _audioPath = result.files.single.path);
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) setState(() => _profileImagePath = result.files.single.path);
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);

    final data = <String, dynamic>{};

    if (_emptyFields.contains("about")) data["about"] = _aboutController.text.trim();
    if (_emptyFields.contains("gender")) data["gender"] = _selectedGender;

    // convert dob to YYYY-MM-DD
    if (_emptyFields.contains("dob") && _dob != null) {
      final dobString = DateFormat('yyyy-MM-dd').format(_dob!);
      data["dob"] = dobString;
    }

    // location field (new)
    if (_emptyFields.contains("location")) {
      final loc = _locationController.text.trim();
      if (loc.isNotEmpty) data["location"] = loc;
    }

    if (_emptyFields.contains("audioUrl") && _audioPath != null) data["audioUrl"] = _audioPath;
    if (_emptyFields.contains("profileImageurl") && _profileImagePath != null) {
      data["profileImageurl"] = _profileImagePath;
    }
    if (_emptyFields.contains("emoji")) data["emoji"] = _selectedEmoji;
    if (_emptyFields.contains("interests")) data["interestIds"] = _selectedInterestIds;

    final success = await GamificationService().updateProfile(data);

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Profile Updated!" : "Update failed")),
    );
    if (success) _loadProfile(); // refresh after update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gamification Form")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_emptyFields.contains("profileImageurl"))
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImagePath != null
                            ? FileImage(File(_profileImagePath!))
                            : const AssetImage("assets/default_profile.png") as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: _pickImage,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              if (_emptyFields.contains("dob"))
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dob == null
                            ? "Select DOB"
                            : "DOB: ${_dob!.day}-${_dob!.month}-${_dob!.year}",
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
                  ],
                ),
              const SizedBox(height: 16),

              if (_emptyFields.contains("gender"))
                Row(
                  children: [
                    const Text("Gender: "),
                    Radio<String>(
                        value: "Male",
                        groupValue: _selectedGender,
                        onChanged: (val) => setState(() => _selectedGender = val)),
                    const Text("Male"),
                    Radio<String>(
                        value: "Female",
                        groupValue: _selectedGender,
                        onChanged: (val) => setState(() => _selectedGender = val)),
                    const Text("Female"),
                  ],
                ),
              const SizedBox(height: 16),

              if (_emptyFields.contains("audioUrl"))
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickAudio,
                      icon: const Icon(Icons.audiotrack),
                      label: const Text("Upload Audio"),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(_audioPath == null ? "No file chosen" : _audioPath!,
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
              const SizedBox(height: 16),

              if (_emptyFields.contains("emoji"))
                DropdownButtonFormField<String>(
                  value: _selectedEmoji,
                  decoration: const InputDecoration(labelText: "Emoji"),
                  items: ["😀", "😎", "🔥", "💡"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedEmoji = v),
                ),
              const SizedBox(height: 16),

              if (_emptyFields.contains("about"))
                TextFormField(
                  controller: _aboutController,
                  decoration: const InputDecoration(labelText: "About"),
                ),
              const SizedBox(height: 16),

              // --------- Location field added ----------
              if (_emptyFields.contains("location"))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: "Location",
                        hintText: "City, State or full address",
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              // ----------------------------------------

              if (_emptyFields.contains("interests"))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Interests"),
                    Wrap(
                      spacing: 10,
                      children: _interestList
                          .map((interest) => FilterChip(
                        label: Text(interest['interestName']),
                        selected: _selectedInterestIds.contains(interest['id']),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedInterestIds.add(interest['id']);
                            } else {
                              _selectedInterestIds.remove(interest['id']);
                            }
                          });
                        },
                      ))
                          .toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
