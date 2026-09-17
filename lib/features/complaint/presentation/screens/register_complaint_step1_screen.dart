import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../shell/presentation/providers/navigation_provider.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../../data/location_api_service.dart';
import '../widgets/complaint_dropdown_field.dart';
import '../widgets/complaint_step_header.dart';
import 'register_complaint_step2_screen.dart';

class RegisterComplaintStep1Screen extends StatefulWidget {
  final String selectedLanguage;
  final bool isNestedInShell;

  const RegisterComplaintStep1Screen({
    super.key,
    required this.selectedLanguage,
    this.isNestedInShell = false,
  });

  @override
  State<RegisterComplaintStep1Screen> createState() =>
      _RegisterComplaintStep1ScreenState();
}

class _RegisterComplaintStep1ScreenState
    extends State<RegisterComplaintStep1Screen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _addressController;
  late final TextEditingController _pincodeController;

  final LocationApiService _locationService = LocationApiService();
  List<TalukModel> _dynamicTaluks = [];
  List<VillageModel> _dynamicVillages = [];
  bool _isLoadingTaluks = false;
  bool _isLoadingVillages = false;

  String _selectedTaluk = '';
  String _selectedVillage = '';
  String _canonicalTalukEn = '';

  final int _currentBottomIndex = 1; // Active on Register tab

  @override
  void initState() {
    super.initState();
    final user = SessionService.instance.currentUser;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _mobileController = TextEditingController(text: user?.mobile ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _pincodeController = TextEditingController(text: '606202');

    final isTamil = widget.selectedLanguage == 'ta';
    _selectedTaluk = isTamil ? 'வட்டத்தைத் தேர்ந்தெடுக்கவும்' : 'Select Taluk';
    _selectedVillage = isTamil ? 'கிராமத்தைத் தேர்ந்தெடுக்கவும்' : 'Select Village';

    SessionService.instance.addListener(_onSessionUpdated);
    _loadTaluks();
  }

  void _onSessionUpdated() {
    if (!mounted) return;
    final user = SessionService.instance.currentUser;
    if (user != null) {
      setState(() {
        if (_fullNameController.text != user.fullName) {
          _fullNameController.text = user.fullName;
        }
        if (_mobileController.text != user.mobile) {
          _mobileController.text = user.mobile;
        }
        final currentAddr = user.address ?? '';
        if (_addressController.text != currentAddr) {
          _addressController.text = currentAddr;
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant RegisterComplaintStep1Screen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLanguage != widget.selectedLanguage) {
      final isTamil = widget.selectedLanguage == 'ta';
      final oldIsTamil = oldWidget.selectedLanguage == 'ta';
      final oldDefaultTaluk = oldIsTamil ? 'வட்டத்தைத் தேர்ந்தெடுக்கவும்' : 'Select Taluk';
      final oldDefaultVillage = oldIsTamil ? 'கிராமத்தைத் தேர்ந்தெடுக்கவும்' : 'Select Village';

      if (_selectedTaluk.isEmpty || _selectedTaluk == oldDefaultTaluk) {
        _selectedTaluk = isTamil ? 'வட்டத்தைத் தேர்ந்தெடுக்கவும்' : 'Select Taluk';
      } else if (_canonicalTalukEn.isNotEmpty) {
        for (final t in _dynamicTaluks) {
          if (t.nameEn == _canonicalTalukEn) {
            _selectedTaluk = isTamil ? t.nameTa : t.nameEn;
            break;
          }
        }
      }
      if (_selectedVillage.isEmpty || _selectedVillage == oldDefaultVillage) {
        _selectedVillage = isTamil ? 'கிராமத்தைத் தேர்ந்தெடுக்கவும்' : 'Select Village';
      }
      setState(() {});
    }
  }

  Future<void> _loadTaluks() async {
    setState(() => _isLoadingTaluks = true);
    final taluks = await _locationService.getTaluks();
    if (mounted) {
      setState(() {
        _dynamicTaluks = taluks;
        _isLoadingTaluks = false;
      });
    }
  }

  void _onTalukChanged(String? val) {
    if (val == null) return;
    final isTamil = widget.selectedLanguage == 'ta';
    final defaultTaluk = isTamil ? 'வட்டத்தைத் தேர்ந்தெடுக்கவும்' : 'Select Taluk';
    final defaultVillage = isTamil ? 'கிராமத்தைத் தேர்ந்தெடுக்கவும்' : 'Select Village';

    setState(() {
      _selectedTaluk = val;
      _selectedVillage = defaultVillage;
    });

    if (val == defaultTaluk ||
        val == 'Taluk' ||
        val == 'வட்டம்' ||
        val == 'Select Taluk' ||
        val == 'வட்டத்தைத் தேர்ந்தெடுக்கவும்' ||
        val == 'வட்டத்தைத் தேர்ந்தெடுக்க' ||
        val == 'வட்டங்கள் இல்லை' ||
        val == 'No taluks available' ||
        val == 'ஏற்றுகிறது...' ||
        val == 'Loading...' ||
        val.trim().isEmpty) {
      setState(() {
        _dynamicVillages = [];
        _canonicalTalukEn = '';
      });
      return;
    }

    // Match TalukModel from dynamic DB list
    TalukModel? matched;
    for (final t in _dynamicTaluks) {
      if (t.nameTa == val || t.nameEn == val) {
        matched = t;
        break;
      }
    }

    final talukEn = matched?.nameEn ?? val;
    _canonicalTalukEn = talukEn;
    _fetchVillages(talukEn);
  }

  Future<void> _fetchVillages(String talukQuery) async {
    setState(() => _isLoadingVillages = true);
    final villages = await _locationService.getVillages(taluk: talukQuery);
    if (mounted) {
      setState(() {
        _dynamicVillages = villages;
        _isLoadingVillages = false;
      });
    }
  }

  void _onVillageChanged(String? val) {
    if (val == null) return;
    setState(() {
      _selectedVillage = val;
    });

    // Auto-fill pincode if village has one
    for (final v in _dynamicVillages) {
      if ((v.nameTa == val || v.nameEn == val) &&
          v.pincode != null &&
          v.pincode!.trim().isNotEmpty) {
        _pincodeController.text = v.pincode!.trim();
        break;
      }
    }
  }

  bool _isTalukSelected() {
    return _selectedTaluk.isNotEmpty &&
        _selectedTaluk != 'Select Taluk' &&
        _selectedTaluk != 'வட்டத்தைத் தேர்ந்தெடுக்கவும்' &&
        _selectedTaluk != 'Taluk' &&
        _selectedTaluk != 'வட்டம்' &&
        _selectedTaluk != 'வட்டத்தைத் தேர்ந்தெடுக்க' &&
        _selectedTaluk != 'வட்டங்கள் இல்லை' &&
        _selectedTaluk != 'No taluks available' &&
        _selectedTaluk != 'ஏற்றுகிறது...' &&
        _selectedTaluk != 'Loading...';
  }

  bool _isVillageSelected() {
    return _selectedVillage.isNotEmpty &&
        _selectedVillage != 'Select Village' &&
        _selectedVillage != 'கிராமத்தைத் தேர்ந்தெடுக்கவும்' &&
        _selectedVillage != 'Village' &&
        _selectedVillage != 'கிராமம்' &&
        _selectedVillage != 'கிராமத்தைத் தேர்ந்தெடுக்க' &&
        _selectedVillage != 'Select' &&
        _selectedVillage != 'தேர்ந்தெடுக்க' &&
        _selectedVillage != 'கிராமங்கள் இல்லை' &&
        _selectedVillage != 'No villages found' &&
        _selectedVillage != 'ஏற்றுகிறது...' &&
        _selectedVillage != 'Loading...';
  }

  @override
  void dispose() {
    SessionService.instance.removeListener(_onSessionUpdated);
    _fullNameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    final isTamil = widget.selectedLanguage == 'ta';

    if (_fullNameController.text.trim().isEmpty) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து உங்கள் முழு பெயரை உள்ளிடவும்!'
            : 'Please enter your full name!',
      );
      return;
    }

    if (_mobileController.text.trim().length < 10) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து சரியான 10 இலக்க கைபேசி எண்ணை உள்ளிடவும்!'
            : 'Please enter a valid 10-digit mobile number!',
      );
      return;
    }

    if (!_isTalukSelected()) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து உங்கள் வட்டத்தைத் தேர்ந்தெடுக்கவும்!'
            : 'Please select your Taluk!',
      );
      return;
    }

    if (!_isVillageSelected()) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து உங்கள் கிராமம் அல்லது வார்டைத் தேர்ந்தெடுக்கவும்!'
            : 'Please select your Village / Ward!',
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து உங்கள் தெரு / கதவு எண் முகவரியை உள்ளிடவும்!'
            : 'Please enter your door number and street address!',
      );
      return;
    }

    // Pass data to Step 2
    final talukEn = _canonicalTalukEn.isNotEmpty ? _canonicalTalukEn : _selectedTaluk;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterComplaintStep2Screen(
          selectedLanguage: widget.selectedLanguage,
          step1Data: {
            'fullName': _fullNameController.text.trim(),
            'mobile': _mobileController.text.trim(),
            'taluk': talukEn,
            'village': _selectedVillage,
            'address': _addressController.text.trim(),
            'pincode': _pincodeController.text.trim(),
          },
        ),
      ),
    );
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      try {
        final nav = Provider.of<NavigationProvider>(context, listen: false);
        nav.setIndex(0, context);
      } catch (_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainShellScreen(
              initialIndex: 0,
              selectedLanguage: widget.selectedLanguage,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.selectedLanguage == 'ta';
    final isTablet = Responsive.isTablet(context);
    final size = MediaQuery.of(context).size;

    // Ensure controllers stay in sync with updated profile data
    final user = SessionService.instance.currentUser;
    if (user != null) {
      if (_fullNameController.text.isEmpty && user.fullName.isNotEmpty) {
        _fullNameController.text = user.fullName;
      }
      if (_mobileController.text.isEmpty && user.mobile.isNotEmpty) {
        _mobileController.text = user.mobile;
      }
      if (_addressController.text.isEmpty && (user.address?.isNotEmpty ?? false)) {
        _addressController.text = user.address!;
      }
    }

    // Dynamic Taluks List with clean 'Select Taluk' placeholder
    final defaultTalukInitial = isTamil ? 'வட்டத்தைத் தேர்ந்தெடுக்கவும்' : 'Select Taluk';
    final List<String> talukItems = [defaultTalukInitial];
    if (_isLoadingTaluks) {
      talukItems.add(isTamil ? 'ஏற்றுகிறது...' : 'Loading...');
    } else if (_dynamicTaluks.isNotEmpty) {
      talukItems.addAll(_dynamicTaluks.map((t) => isTamil ? t.nameTa : t.nameEn));
    } else {
      talukItems.add(isTamil ? 'வட்டங்கள் இல்லை' : 'No taluks available');
    }

    // Dynamic Villages List with clean 'Select Village' placeholder
    final defaultVillageInitial = isTamil ? 'கிராமத்தைத் தேர்ந்தெடுக்கவும்' : 'Select Village';
    List<String> villageItems = [defaultVillageInitial];

    if (_isLoadingVillages) {
      villageItems = [isTamil ? 'ஏற்றுகிறது...' : 'Loading...'];
    } else if (_dynamicVillages.isNotEmpty) {
      villageItems.addAll(
        _dynamicVillages.map((v) => isTamil ? v.nameTa : v.nameEn).toList(),
      );
    } else if (_isTalukSelected()) {
      villageItems.add(isTamil ? 'கிராமங்கள் இல்லை' : 'No villages found');
    }

    return PopScope(
      canPop: !widget.isNestedInShell && Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F6F6),
        body: SafeArea(
          child: Column(
            children: [
              // Fixed Compact Top Header Bar
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? size.width * 0.15 : 16,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F6F6),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFEBE5E5), width: 0.8),
                  ),
                ),
                child: ComplaintStepHeader(
                  title: isTamil ? 'புகார் பதிவு' : 'Register Complaint',
                  stepSubtitle: isTamil ? 'படி 1 / 2' : 'STEP 1 OF 2',
                  onBackPressed: _handleBack,
                ),
              ),

              // Scrollable Form Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? size.width * 0.15 : 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFEBE5E5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FULL NAME (AUTO-FILLED)
                      _buildFieldLabel(isTamil ? 'முழு பெயர்' : 'FULL NAME'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _fullNameController,
                        hintText: isTamil ? 'முழு பெயர்' : 'Full Name',
                      ),

                      const SizedBox(height: 18),

                      // MOBILE NUMBER (AUTO-FILLED)
                      _buildFieldLabel(isTamil ? 'கைபேசி எண்' : 'MOBILE NUMBER'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5DCDC)),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '+91',
                              style: TextStyle(
                                color: Color(0xFF6B0000),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 20,
                              width: 1,
                              color: const Color(0xFFD4C5C5),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _mobileController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                style: const TextStyle(
                                  color: Color(0xFF2C0000),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            // Verified Green Checkmark Badge Icon
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF389E0D),
                              size: 22,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // CONSTITUENCY (FIXED / LOCKED)
                      _buildFieldLabel(isTamil ? 'தொகுதி' : 'CONSTITUENCY'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F5F5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5DCDC)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isTamil ? 'கள்ளக்குறிச்சி (No. 80)' : 'Kallakurichi (No. 80)',
                              style: const TextStyle(
                                color: Color(0xFF2C0000),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xFF8E7E7E),
                              size: 18,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // TALUK DROPDOWN (FULL WIDTH, ONE BY ONE)
                      ComplaintDropdownField(
                        label: isTamil ? 'வட்டம்' : 'TALUK',
                        selectedValue: talukItems.contains(_selectedTaluk)
                            ? _selectedTaluk
                            : talukItems.first,
                        items: talukItems,
                        onChanged: _onTalukChanged,
                      ),

                      const SizedBox(height: 18),

                      // VILLAGE DROPDOWN (FULL WIDTH, ONE BY ONE)
                      ComplaintDropdownField(
                        label: isTamil ? 'கிராமம் / வார்டு' : 'VILLAGE / WARD',
                        selectedValue: villageItems.contains(_selectedVillage)
                            ? _selectedVillage
                            : villageItems.first,
                        items: villageItems,
                        onChanged: _onVillageChanged,
                      ),

                      const SizedBox(height: 18),

                      // FULL ADDRESS TEXTAREA (AUTO-FILLED)
                      _buildFieldLabel(
                          isTamil ? 'முகவரி (தெரு / கதவு எண்)' : 'FULL ADDRESS'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _addressController,
                        hintText: isTamil
                            ? 'தெரு பெயர், கதவு எண், பகுதி...'
                            : 'Door No, Street Name, Area...',
                        maxLines: 3,
                      ),

                      const SizedBox(height: 18),

                      // PINCODE
                      _buildFieldLabel(
                          isTamil ? 'அஞ்சல் குறியீடு' : 'PINCODE'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _pincodeController,
                        hintText: isTamil ? 'அஞ்சல் குறியீடு' : 'Pincode',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // NEXT BUTTON
                      CustomButton(
                        text: isTamil ? 'அடுத்தது ➔' : 'Next ➔',
                        onPressed: _onNextPressed,
                        height: isTablet ? 54 : 48,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
      bottomNavigationBar: widget.isNestedInShell
          ? null
          : CustomBottomNavBar(
              currentIndex: _currentBottomIndex,
              selectedLanguage: widget.selectedLanguage,
            ),
    ),
  );
}

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF6E6E6E),
        fontSize: 11.5,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DCDC)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        style: const TextStyle(
          color: Color(0xFF2C0000),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
