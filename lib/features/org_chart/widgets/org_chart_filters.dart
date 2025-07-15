import 'package:flutter/material.dart';

class OrgChartFilters extends StatelessWidget {
  final String? selectedDepartment;
  final String? selectedDesignation;
  final Function(String?) onDepartmentChanged;
  final Function(String?) onDesignationChanged;

  const OrgChartFilters({
    super.key,
    this.selectedDepartment,
    this.selectedDesignation,
    required this.onDepartmentChanged,
    required this.onDesignationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildDepartmentFilter()),
        const SizedBox(width: 12),
        Expanded(child: _buildDesignationFilter()),
      ],
    );
  }

  Widget _buildDepartmentFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedDepartment,
        onChanged: onDepartmentChanged,
        decoration: const InputDecoration(
          hintText: 'All Departments',
          prefixIcon: Icon(Icons.business, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _getDepartmentItems(),
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildDesignationFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedDesignation,
        onChanged: onDesignationChanged,
        decoration: const InputDecoration(
          hintText: 'All Designations',
          prefixIcon: Icon(Icons.work, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _getDesignationItems(),
        dropdownColor: Colors.white,
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDepartmentItems() {
    // Common departments - in a real app, this would come from the database
    final departments = [
      'Engineering',
      'Human Resources',
      'Finance',
      'Marketing',
      'Sales',
      'Operations',
      'Legal',
      'IT',
      'Customer Support',
      'Product Management',
    ];

    return [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('All Departments'),
      ),
      ...departments.map(
        (dept) => DropdownMenuItem<String>(value: dept, child: Text(dept)),
      ),
    ];
  }

  List<DropdownMenuItem<String>> _getDesignationItems() {
    // Common designations - in a real app, this would come from the database
    final designations = [
      'CEO',
      'CTO',
      'CFO',
      'Director',
      'Vice President',
      'General Manager',
      'Manager',
      'Assistant Manager',
      'Team Lead',
      'Senior Executive',
      'Executive',
      'Senior Associate',
      'Associate',
      'Junior Associate',
      'Trainee',
      'Intern',
    ];

    return [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('All Designations'),
      ),
      ...designations.map(
        (designation) => DropdownMenuItem<String>(
          value: designation,
          child: Text(designation),
        ),
      ),
    ];
  }
}
