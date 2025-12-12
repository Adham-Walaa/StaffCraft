using System;

namespace WebAppSystem.Models
{
    public class OrgHierarchyViewModel
    {
        public int? EmployeeId { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? EmployeeName { get; set; }
        public int? ManagerId { get; set; }
        public string? ManagerName { get; set; }
        public int? DepartmentId { get; set; }
        public string? DepartmentName { get; set; }
        public int? PositionId { get; set; }
        public string? PositionTitle { get; set; }
        public int? HierarchyLevel { get; set; }
        public string? HierarchyPath { get; set; }
    }
}
