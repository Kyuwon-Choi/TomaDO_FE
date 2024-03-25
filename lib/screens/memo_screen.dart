import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:tomado/data/preference_manager.dart';
import 'package:tomado/models/memo_model.dart';
import 'dart:convert';

import 'package:tomado/services/memo_api_service.dart';

class MemoScreen extends StatefulWidget {
  const MemoScreen({Key? key}) : super(key: key);

  @override
  _MemoScreenState createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  List<MemoModel> memos = [];

  @override
  void initState() {
    super.initState();
    _fetchMemoList();
  }

  Future<void> _fetchMemoList() async {
    try {
      // PreferenceManager에서 userId를 가져옵니다.
      final String? userId = await PreferenceManager.getUserId();
      if (userId != null) {
        // userId가 존재하는 경우, API 호출에 userId를 인자로 사용합니다.
        memos = await MemoApiService().fetchMemoList(int.parse(userId));
        setState(() {}); // UI를 새로운 데이터로 업데이트하기 위해 호출합니다.
      } else {
        // userId가 존재하지 않는 경우, 사용자에게 알립니다.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자 ID가 설정되지 않았습니다.')),
        );
      }
    } catch (e) {
      // 데이터를 가져오는데 실패한 경우 사용자에게 알립니다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메모를 불러오는데 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '긴급 메모',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: memos.length,
              itemBuilder: (context, index) {
                final memo = memos[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      memo.content,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    subtitle: Text(
                      DateFormat('yyyy.MM.dd').format(memo.createdAt),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
