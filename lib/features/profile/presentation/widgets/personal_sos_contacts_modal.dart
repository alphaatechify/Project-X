import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_x/app/theme/app_colors.dart';

class PersonalContact {
  String name;
  String phone;
  String relation;

  PersonalContact({
    required this.name,
    required this.phone,
    required this.relation,
  });
}

class PersonalSosContactsModal extends StatefulWidget {
  const PersonalSosContactsModal({super.key});

  @override
  State<PersonalSosContactsModal> createState() => _PersonalSosContactsModalState();
}

class _PersonalSosContactsModalState extends State<PersonalSosContactsModal> {
  final List<PersonalContact> _contacts = [
    PersonalContact(name: 'Ramesh Sharma', phone: '+91 98123 45678', relation: 'Father'),
    PersonalContact(name: 'Priya Sharma', phone: '+91 98765 12345', relation: 'Spouse'),
    PersonalContact(name: 'Amit Verma', phone: '+91 99001 88223', relation: 'Friend'),
  ];

  void _showAddContactDialog() {
    if (_contacts.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum 3 emergency contacts allowed.', style: GoogleFonts.inter()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String relationVal = 'Family';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Emergency Contact', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Contact Name',
                labelStyle: GoogleFonts.inter(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number (+91)',
                labelStyle: GoogleFonts.inter(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: relationVal,
              items: ['Father', 'Mother', 'Spouse', 'Sibling', 'Friend', 'Neighbor']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r, style: GoogleFonts.inter(fontSize: 13))))
                  .toList(),
              onChanged: (val) => relationVal = val ?? 'Family',
              decoration: InputDecoration(
                labelText: 'Relationship',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                setState(() {
                  _contacts.add(PersonalContact(
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    relation: relationVal,
                  ));
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Save Contact', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _sendSosAlert() {
    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least 1 emergency contact first.', style: GoogleFonts.inter()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final names = _contacts.map((c) => c.name).join(', ');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 26),
            const SizedBox(width: 8),
            Text('SEND SOS ALERT?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.red)),
          ],
        ),
        content: Text(
          'This will immediately send your live GPS location (12.9716° N, 77.5946° E) via SMS to: $names.',
          style: GoogleFonts.inter(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '🚨 Live Location SOS sent to $names!',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('SEND SOS NOW', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: Icon(Icons.sos_rounded, color: Color(0xFFDC2626), size: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal SOS Contacts',
                      style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    Text(
                      'Add up to 3 trusted emergency contacts',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // Red Broadcast Button
          InkWell(
            onTap: _sendSosAlert,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.my_location_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'SEND LIVE LOCATION SOS',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SAVED CONTACTS (${_contacts.length}/3)',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.6),
              ),
              if (_contacts.length < 3)
                InkWell(
                  onTap: _showAddContactDialog,
                  child: Text(
                    '+ ADD CONTACT',
                    style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w800, color: const Color(0xFF854D0E)),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Contacts List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _contacts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final c = _contacts[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFFEF08A),
                      radius: 20,
                      child: Text(
                        c.name.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(c.name, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(6)),
                                child: Text(c.relation, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF0369A1))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(c.phone, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        setState(() {
                          _contacts.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
