import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {

  final String stationName;

  const ReviewPage({
    super.key,
    required this.stationName,
  });

  @override
  State<ReviewPage> createState() =>
      _ReviewPageState();
}

class _ReviewPageState
    extends State<ReviewPage> {

  final TextEditingController
  reviewController =
  TextEditingController();

  double rating = 3;

  Future<void> submitReview() async {

    await FirebaseFirestore.instance
        .collection('reviews')
        .add({

      'station': widget.stationName,
      'review': reviewController.text,
      'rating': rating,
      'time': DateTime.now(),

    });

    reviewController.clear();

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text(
          "Review Submitted",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        title: Text(widget.stationName),
      ),

        body: SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Column(

          children: [

            const Text(
              "Rate This Station",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: rating.toString(),

              onChanged: (value) {

                setState(() {

                  rating = value;
                });
              },
            ),

            Text(
              "Rating: ${rating.toStringAsFixed(1)} ⭐",
            ),

            const SizedBox(height: 20),

            TextField(
              controller: reviewController,
              maxLines: 4,

              decoration: InputDecoration(
                hintText: "Write your review",
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                onPressed: submitReview,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.green[800],
                  foregroundColor: Colors.white,
                ),

                child: const Text(
                  "Submit Review",
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "All Reviews",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 300,
              child: StreamBuilder<QuerySnapshot>(

                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .where(
                  'station',
                  isEqualTo:
                  widget.stationName,
                )
                    .snapshots(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {

                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  var docs =
                      snapshot.data!.docs;

                  if (docs.isEmpty) {

                    return const Center(
                      child: Text(
                        "No Reviews Yet",
                      ),
                    );
                  }

                  return ListView.builder(

                    itemCount: docs.length,

                    itemBuilder: (context, index) {

                      var data =
                      docs[index];

                      return Card(

                        child: ListTile(

                          leading: CircleAvatar(
                            backgroundColor:
                            Colors.green[800],
                            child: Text(
                              "${data['rating']}",
                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                              ),
                            ),
                          ),

                          title: Text(
                            "${data['rating']} ⭐",
                          ),

                          subtitle: Text(
                            data['review'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],


                    ),
                  ),
                ),
            ),
            ),
        );
  }
}