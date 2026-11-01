import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/apply_viewmodel.dart';
import 'password_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUpload(ApplyViewModel vm, String docType, String folder) async {
    // Pick an image from the gallery
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery); 
    
    if (image != null) {
      final file = File(image.path);
      
      // Upload to Supabase
      final success = await vm.uploadFile(file, folder);
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload document.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ApplyViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7A56B),
        title: const Text('PTO Application - Documents', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                child: const Text('PTO Application - Required documents', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDocumentRow(
                      context,
                      title: 'Certified ID copy',
                      isUploaded: viewModel.certifiedIdUrl != null,
                      isUploading: viewModel.isUploading,
                      onUpload: () => _pickAndUpload(viewModel, 'id', 'certified_ids'),
                    ),
                    const Divider(),
                    _buildDocumentRow(
                      context,
                      title: 'Proof of income',
                      isUploaded: viewModel.proofOfIncomeUrl != null,
                      isUploading: viewModel.isUploading,
                      onUpload: () => _pickAndUpload(viewModel, 'income', 'proof_of_income'),
                    ),
                    const Divider(),
                    _buildDocumentRow(
                      context,
                      title: 'Dependent ID',
                      isUploaded: viewModel.dependentIdUrl != null,
                      isUploading: viewModel.isUploading,
                      onUpload: () => _pickAndUpload(viewModel, 'dependent', 'dependent_ids'),
                    ),
                  ],
                ),
              ),

              // Footer Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)), border: Border(top: BorderSide(color: Colors.grey.shade400))),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Optional: Validate that the required docs are uploaded before continuing
                      if (viewModel.certifiedIdUrl == null || viewModel.proofOfIncomeUrl == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload Certified ID and Proof of Income.')));
                        return;
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordScreen()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9C9C9), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Save and Continue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentRow(BuildContext context, {required String title, required bool isUploaded, required bool isUploading, required VoidCallback onUpload}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87))),
          
          if (isUploaded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFD1F2D1), borderRadius: BorderRadius.circular(12)),
              child: const Text('Uploaded', style: TextStyle(color: Color(0xFF155724), fontSize: 12, fontWeight: FontWeight.bold)),
            )
          else
            ElevatedButton(
              onPressed: isUploading ? null : onUpload,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9C9C9), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              child: isUploading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Text('Upload', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }
}