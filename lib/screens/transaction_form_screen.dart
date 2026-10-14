// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/my_transaction.dart';
// import '../providers/transaction_provider.dart';

// class TransactionFormScreen extends StatefulWidget {
//   final MyTransaction? transaction; // เพิ่มตัวแปร transaction
//   const TransactionFormScreen({super.key, this.transaction}); // เพิ่มพารามิเตอร์ transaction

//   @override
//   State<TransactionFormScreen> createState() => _TransactionFormScreenState();
// }
// class _TransactionFormScreenState extends State<TransactionFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late String _title;
//   late double _amount;
//   late DateTime _date;
//   late TransactionType _type;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.transaction != null) {
//       // ถ้ามี transaction ให้ตั้งค่าเริ่มต้นจาก transaction นั้น
//       _title = widget.transaction!.title;
//       _amount = widget.transaction!.amount;
//       _date = widget.transaction!.date;
//       _type = widget.transaction!.type;
//     } else {
//       // ถ้าไม่มี transaction ให้ตั้งค่าเริ่มต้นเป็นค่า default
//       _title = '';
//       _amount = 0.0;
//       _date = DateTime.now();
//       _type = TransactionType.expense; // ค่า default เป็น expense
//     }
//   }
//   Future<void> _saveForm() async {
//     if (!_formKey.currentState!.validate()) return;
//     _formKey.currentState!.save();

//     final provider = context.read<TransactionProvider>();

//     if (widget.transaction == null) {
//       // กรณีเพิ่มรายการใหม่
//       await provider.addTransaction(_title, _amount, _date, _type);
//     } else {
//       // กรณีแก้ไขรายการเดิม
//       final updatedTx = MyTransaction(
//         id: widget.transaction!.id,
//         title: _title,
//         amount: _amount,
//         date: _date,
//         type: _type,
//       );
//       await provider.updateTransaction(widget.transaction!.id!, updatedTx);
//     }

//     if (!mounted) return;
//     Navigator.pop(context); // บันทึกเสร็จแล้วปิดหน้านี้กลับไปหน้าหลัก
//   }

//   }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/my_transaction.dart';
import '../providers/transaction_provider.dart';

class TransactionFormScreen extends StatefulWidget {
  final MyTransaction? transaction; // ถ้ารับค่ามา = แก้ไข, ถ้า null = เพิ่มใหม่
  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. ประกาศตัวแปรเก็บค่า
  late String _title;
  late double _amount;
  late DateTime _date;
  late TransactionType _type;

  @override
  void initState() {
    super.initState();
    // 2. เช็กว่าเป็นการกดเข้ามาเพื่อ "แก้ไข" หรือ "เพิ่มใหม่"
    if (widget.transaction != null) {
      _title = widget.transaction!.title;
      _amount = widget.transaction!.amount;
      _date = widget.transaction!.date;
      _type = widget.transaction!.type;
    } else {
      _title = '';
      _amount = 0.0;
      _date = DateTime.now();
      _type = TransactionType.expense; // ค่าเริ่มต้นเป็น รายจ่าย
    }
  }

  // 3. ฟังก์ชันบันทึกข้อมูลเข้า Database
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final provider = context.read<TransactionProvider>();

    if (widget.transaction == null) {
      // เพิ่มใหม่
      await provider.addTransaction(_title, _amount, _date, _type);
    } else {
      // แก้ไขรายการเดิม
      final updatedTx = MyTransaction(
        id: widget.transaction!.id,
        title: _title,
        amount: _amount,
        date: _date,
        type: _type,
      );
      await provider.updateTransaction(widget.transaction!.id!, updatedTx);
    }

    if (!mounted) return;
    Navigator.pop(context); // บันทึกเสร็จแล้วปิดหน้านี้ เด้งกลับหน้าแรก
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction != null ? 'แก้ไขรายการ' : 'เพิ่มรายการ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. ช่องกรอกชื่อ
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
                validator: (val) => val!.isEmpty ? 'กรุณากรอกชื่อ' : null,
                onSaved: (val) => _title = val!,
              ),

              // 2. ช่องกรอกจำนวนเงิน
              TextFormField(
                initialValue: _amount == 0.0 ? '' : _amount.toString(),
                decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'กรุณากรอกตัวเลข' : null,
                onSaved: (val) => _amount = double.parse(val!),
              ),

              // 3. เลือกประเภท (รายรับ / รายจ่าย)
              DropdownButtonFormField<TransactionType>(
                value: _type,
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('รายรับ'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('รายจ่าย'),
                  ),
                ],
                onChanged: (val) => setState(() => _type = val!),
              ),

              const SizedBox(height: 20),

              // 4. ปุ่มบันทึก
              ElevatedButton(onPressed: _saveForm, child: const Text('บันทึก')),
            ],
          ),
        ),
      ),
    );
  }
}
