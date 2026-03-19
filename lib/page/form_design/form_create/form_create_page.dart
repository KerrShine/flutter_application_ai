import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/service/form_create_service.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/page/form_design/form_create/bloc/form_create_bloc.dart';
import 'package:flutter_application_ai/page/form_design/form_create/bloc/form_create_event.dart';
import 'package:flutter_application_ai/page/form_design/form_create/bloc/form_create_state.dart';
import 'package:flutter_application_ai/page/form_design/form_create/constant/form_create_constants.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/dialog/loading_dialog.dart';

class FormCreatePage extends StatefulWidget {
  /// 若傳入 [formModel]，則進入「編輯」模式；否則為「新增」模式。
  final FormModel? formModel;
  const FormCreatePage({super.key, this.formModel});

  @override
  State<FormCreatePage> createState() => _FormCreatePageState();
}

class _FormCreatePageState extends State<FormCreatePage> {
  late final FormCreateBloc _bloc;
  final TextEditingController _nameController = TextEditingController();
  bool _isLoadingDialogVisible = false;
  String _selectedSize = 'A4';

  @override
  void initState() {
    super.initState();
    _bloc = FormCreateBloc(sl<FormCreateService>());
    _bloc.add(const InitEvent());
    // 若為編輯模式，預填欄位
    if (widget.formModel != null) {
      _nameController.text = widget.formModel!.name;
      _selectedSize = widget.formModel!.size;
    }
  }

  @override
  void dispose() {
    if (_isLoadingDialogVisible) {
      hideLoadingDialog(context);
      _isLoadingDialogVisible = false;
    }
    _nameController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<FormCreateBloc, FormCreateState>(
            listenWhen: (previous, current) {
              final wasLoading = previous.status == FormCreateStatus.loading;
              final isLoading = current.status == FormCreateStatus.loading;
              return wasLoading != isLoading;
            },
            listener: (context, state) {
              if (state.status == FormCreateStatus.loading) {
                if (!_isLoadingDialogVisible) {
                  _isLoadingDialogVisible = true;
                  showLoadingDialog(context);
                }
              } else if (_isLoadingDialogVisible) {
                hideLoadingDialog(context);
                _isLoadingDialogVisible = false;
              }
            },
          ),
          BlocListener<FormCreateBloc, FormCreateState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == FormCreateStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('表單建立成功')),
                );
                // 成功後直接進入 FormDesignPage 編輯表單
                final newFormId = state.createdForm?.id;
                if (newFormId != null) {
                  context.go(RouteName.formDesignPage, extra: newFormId);
                } else {
                  context.go(RouteName.formManagePage);
                }
              } else if (state.status == FormCreateStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<FormCreateBloc, FormCreateState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.formModel != null ? '編輯表單' : '建置新表單'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              body: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '表單初始設定',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: '表單名稱',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<String>(
                            value: _selectedSize,
                            decoration: const InputDecoration(
                              labelText: '表單大小',
                              border: OutlineInputBorder(),
                            ),
                            items: FormCreateConstants.sizeOptions.map((size) {
                              return DropdownMenuItem(
                                value: size,
                                child: Text(size),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedSize = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              _bloc.add(
                                SubmitFormCreateEvent(
                                  formName: _nameController.text,
                                  formSize: _selectedSize,
                                ),
                              );
                            },
                            child: const Text('建立臨時表單',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
