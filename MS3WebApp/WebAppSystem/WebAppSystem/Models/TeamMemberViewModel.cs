using System;

namespace WebAppSystem.Models
{
    public class TeamMemberViewModel
    {
        // Employee basic information
        public int EmployeeId { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? FullName { get; set; }
        public string? NationalId { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string? CountryOfBirth { get; set; }
        public string? Phone { get; set; }
        public string? Email { get; set; }
        public string? PasswordHash { get; set; }
        public string? Address { get; set; }
        public string? EmergencyContactName { get; set; }
        public string? EmergencyContactPhone { get; set; }
        public string? Relationship { get; set; }
        public string? Biography { get; set; }
        public byte[]? ProfileImage { get; set; }
        public string? EmploymentProgress { get; set; }
        public string? AccountStatus { get; set; }
        public string? EmploymentStatus { get; set; }
        public DateTime? HireDate { get; set; }
        public bool? IsActive { get; set; }
        
        // Foreign keys
        public int? DepartmentId { get; set; }
        public int? PositionId { get; set; }
        public int? PaygradeId { get; set; }
        public int? TaxformId { get; set; }
        public int? ManagerId { get; set; }
        public int? SalaryTypeId { get; set; }
        public int? ContractId { get; set; }
        public int? ProfileCompletionPercentage { get; set; }
        
        // Hierarchy information
        public int HierarchyLevel { get; set; }
        public string? HierarchyPath { get; set; }
        
        // Navigation properties (to be loaded separately)
        public Department? Department { get; set; }
        public Position? Position { get; set; }
        public Employee? Manager { get; set; }
    }
}
