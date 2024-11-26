import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task/screens/image_view_screen.dart';
import 'package:task/screens/pdf_view_screen.dart';
import 'package:http/http.dart' as http;

class UserTicketDetailsScreen extends StatelessWidget {
  const UserTicketDetailsScreen({super.key, required this.ticket});
  final Map<String, dynamic> ticket;
  Future<String?> _getFileType(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.headers['content-type'];
    } catch (e) {
      return null; // Handle errors gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade600,
        title: const Text('Ticket Details'),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title: ${ticket['title']}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      'Description:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      ticket['description'] ?? 'No description provided',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          ticket['status'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ticket['status'] == 'Approved'
                                ? Colors.green
                                : ticket['status'] == 'Rejected'
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    if (ticket['mainCategory'] == 'leaves') ...[
                      const Divider(height: 24),
                      Text(
                        'Leave Dates:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ...((ticket['datesOfRequirement'] ?? []) as List)
                          .map((date) => Text(
                                DateFormat(
                                        'yyyy-MM-dd') // Format date as "2024-11-17"
                                    .format((date as Timestamp).toDate()),
                                style: const TextStyle(fontSize: 16),
                              )),
                    ],
                    if (ticket['mainCategory'] == 'renumration') ...[
                      const Divider(height: 24),
                      Text('Main Category: ${ticket['mainCategory']}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Sub Category: ${ticket['subCategory']}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold)),
                    ],
                    if (ticket['status'] == 'Rejected' &&
                        ticket.containsKey('adminMessage')) ...[
                      const SizedBox(height: 24),
                      Text('Rejection Reason:',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.red.shade700)),
                      Text(
                        ticket['adminMessage'] ?? 'No reason provided',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    if (ticket['attachments'] != null &&
                        (ticket['attachments'] as List).isNotEmpty) ...[
                      const Divider(height: 24),
                      Text(
                        'Attachments:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ...((ticket['attachments'] as List).map(
                        (fileUrl) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                fileUrl,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  // decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow
                                    .ellipsis, // To handle long URLs gracefully
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () async {
                                {
                                  final fileType = await _getFileType(fileUrl);
                                  if (fileType == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Could not determine file type')),
                                    );
                                    return;
                                  }
        
                                  if (fileType.contains('pdf')) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PdfViewerScreen(fileUrl: fileUrl),
                                      ),
                                    );
                                  } else if (fileType.contains('image')) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ImageViewerScreen(fileUrl: fileUrl),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Unsupported file type')),
                                    );
                                  }
                                }
                                ;
                              },
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
