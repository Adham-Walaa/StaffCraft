-- ========================================
-- DATABASE CREATION
-- ========================================
CREATE DATABASE MILESTONE2;
GO
USE MILESTONE2;
GO

-- ========================================
-- TABLE CREATION
-- ========================================

CREATE TABLE Employee
(
    EmployeeID int PRIMARY KEY,
    first_name varchar(50),
    last_name varchar(50),
    full_name AS (first_name + ' ' + last_name) PERSISTED,
    national_id varchar(20),
    date_of_birth datetime,
    country_of_birth varchar(50),
    phone varchar(15),
    email varchar(100),
    password_hash varchar(255),
    address varchar(200),
    emergency_contact_name varchar(100),
    emergency_contact_phone varchar(15),
    relationship varchar(50),
    biography text,
    profile_image varbinary(max),
    employment_progress varchar(100),
    account_status varchar(50),
    employment_status varchar(50),
    hire_date datetime,
    is_active bit DEFAULT 1,
    department_id int,
    position_id int,
    paygrade_id int,
    taxform_id int,
    manager_id int,
    salary_type_id int,
    contract_id int,
    profile_completion_percentage int CHECK (profile_completion_percentage BETWEEN 0 AND 100)
);

CREATE TABLE HRAdministrator
(
    employee_id int,
    approval_level varchar(50),
    record_access_scope varchar(100),
    document_validation_rights bit
);

CREATE TABLE SystemAdministrator
(
    employee_id int,
    system_privilege_level varchar(50),
    configurable_fields text,
    audit_visibility_scope varchar(100)
);

CREATE TABLE PayrollSpecialist
(
    employee_id int,
    assigned_region varchar(100),
    processing_frequency varchar(50),
    last_processed_period datetime
);

CREATE TABLE LineManager
(
    employee_id int,
    team_size int,
    supervised_departments varchar(200),
    approval_limit decimal(18,2)
);

CREATE TABLE Position
(
    PositionID int PRIMARY KEY,
    position_title varchar(100),
    responsibilities text,
    status varchar(50)
);

CREATE TABLE Department
(
    DepartmentID int PRIMARY KEY,
    department_name varchar(100),
    purpose text,
    department_head_id int
);

CREATE TABLE Skill
(
    SkillID int PRIMARY KEY,
    skill_name varchar(100),
    description text
);

CREATE TABLE EmployeeSkill
(
    employee_id int,
    skill_id int,
    proficiency_level varchar(50)
);

CREATE TABLE Verification
(
    VerificationID int PRIMARY KEY,
    verification_type varchar(100),
    issuer varchar(100),
    issue_date date,
    expiry_period date
);

CREATE TABLE EmployeeVerification
(
    employee_id int,
    verification_id int
);

CREATE TABLE Role
(
    RoleID int PRIMARY KEY,
    role_name varchar(100),
    purpose text
);

CREATE TABLE EmployeeRole
(
    employee_id int,
    role_id int,
    assigned_date datetime
);

CREATE TABLE RolePermission
(
    role_id int,
    permission_name varchar(100),
    allowed_action varchar(100)
);

CREATE TABLE Contract
(
    ContractID int PRIMARY KEY,
    type varchar(100),
    start_date datetime,
    end_date datetime,
    current_state varchar(50)
);

CREATE TABLE FullTimeContract
(
    contract_id int,
    leave_entitlement int,
    insurance_eligibility bit,
    weekly_working_hours int
);

CREATE TABLE PartTimeContract
(
    contract_id int,
    working_hours int,
    hourly_rate decimal(18,2)
);

CREATE TABLE ConsultantContract
(
    contract_id int,
    project_scope text,
    fees decimal(18,2),
    payment_schedule varchar(100)
);

CREATE TABLE InternshipContract
(
    contract_id int,
    mentoring varchar(200),
    evaluation text,
    stipend_related decimal(18,2)
);

CREATE TABLE Insurance
(
    InsuranceID int PRIMARY KEY,
    type varchar(100),
    contribution_rate decimal(5,2),
    coverage text
);

CREATE TABLE Termination
(
    TerminationID int PRIMARY KEY,
    date date,
    reason text,
    contract_id int
);

CREATE TABLE Reimbursement
(
    ReimbursementID int PRIMARY KEY,
    type varchar(100),
    claim_type varchar(100),
    approval_date datetime,
    current_status varchar(50),
    employee_id int
);

CREATE TABLE Mission
(
    MissionID int PRIMARY KEY,
    destination varchar(100),
    start_date datetime,
    end_date datetime,
    status varchar(50),
    employee_id int,
    manager_id int
);

CREATE TABLE Leave
(
    LeaveID int PRIMARY KEY,
    leave_type varchar(100),
    leave_description text
);

CREATE TABLE VacationLeave
(
    leave_id int,
    carry_over_days int,
    approving_manager varchar(100)
);

CREATE TABLE SickLeave
(
    leave_id int,
    medical_certificate_required bit,
    physician_id int
);

CREATE TABLE ProbationLeave
(
    leave_id int,
    eligibility_start_date datetime,
    probation_period int
);

CREATE TABLE HolidayLeave
(
    leave_id int,
    holiday_name varchar(100),
    official_recognition bit,
    regional_scope varchar(100)
);

CREATE TABLE LeavePolicy
(
    PolicyID int PRIMARY KEY,
    name varchar(100),
    purpose text,
    eligibility_rules text,
    notice_period datetime,
    special_leave_type varchar(100),
    reset_on_new_year bit
);

CREATE TABLE LeaveRequest
(
    RequestID int PRIMARY KEY,
    employee_id int,
    leave_id int,
    justification text,
    duration int,
    approval_timing datetime,
    status varchar(50)
);

CREATE TABLE LeaveEntitlement
(
    employee_id int,
    leave_type_id int,
    entitlement int
);

CREATE TABLE LeaveDocument
(
    DocumentID int PRIMARY KEY,
    leave_request_id int,
    file_path varchar(200),
    uploaded_at datetime
);

CREATE TABLE Attendance
(
    AttendanceID int PRIMARY KEY,
    employee_id int,
    entry_time time,
    exit_time time,
    duration int,
    login_method varchar(50),
    logout_method varchar(50),
    exception_id int
);

CREATE TABLE AttendanceLog
(
    AttendanceLogID int PRIMARY KEY,
    attendance_id int,
    actor varchar(100),
    timestamp datetime,
    reason text
);

CREATE TABLE AttendanceCorrectionRequest
(
    RequestID int PRIMARY KEY,
    employee_id int,
    date date,
    correction_type varchar(100),
    reason text,
    status varchar(50),
    recommended_by int
);

CREATE TABLE ShiftSchedule
(
    ShiftID int PRIMARY KEY,
    employee_id int,
    start_date datetime,
    end_date datetime,
    status varchar(50)
);

CREATE TABLE Exception
(
    ExceptionID int PRIMARY KEY,
    name varchar(100),
    category varchar(100),
    date datetime,
    status varchar(50)
);

CREATE TABLE EmployeeException
(
    employee_id int,
    exception_id int
);

CREATE TABLE Payroll
(
    PayrollID int PRIMARY KEY,
    employee_id int,
    taxes decimal(18,2),
    period_start datetime,
    period_end datetime,
    base_amount decimal(18,2),
    adjustments decimal(18,2),
    contributions decimal(18,2),
    actual_pay decimal(18,2),
    net_salary decimal(18,2),
    payment_date datetime
);

CREATE TABLE Currency
(
    CurrencyCode varchar(10) PRIMARY KEY,
    currency_name varchar(50),
    exchange_rate decimal(18,4),
    created_date datetime,
    last_updated datetime
);

CREATE TABLE SalaryType
(
    SalaryTypeID int PRIMARY KEY,
    type varchar(100),
    payment_frequency varchar(50),
    currency varchar(10)
);

CREATE TABLE HourlySalaryType
(
    salary_type_id int,
    hourly_rate decimal(18,2),
    max_monthly_hours int
);

CREATE TABLE MonthlySalaryType
(
    salary_type_id int,
    tax_rule varchar(100),
    contribution_scheme varchar(100)
);

CREATE TABLE ContractSalaryType
(
    salary_type_id int,
    contract_value decimal(18,2),
    installement_details varchar(200)
);

CREATE TABLE AllowanceDeduction
(
    AllowanceDeductionID int PRIMARY KEY,
    payroll_id int,
    employee_id int,
    type varchar(50),
    amount decimal(18,2),
    currency varchar(10),
    duration int,
    timezone varchar(50)
);

CREATE TABLE PayrollPolicy
(
    PolicyID int PRIMARY KEY,
    effective_date datetime,
    type varchar(100),
    description text
);

CREATE TABLE OvertimePolicy
(
    policy_id int,
    weekday_rate_multiplier decimal(5,2),
    weekend_rate_multiplier decimal(5,2),
    max_hours_per_month int
);

CREATE TABLE LatenessPolicy
(
    policy_id int,
    grace_period_minutes int,
    deduction_rate decimal(5,2)
);

CREATE TABLE BonusPolicy
(
    policy_id int,
    bonus_type varchar(100),
    eligibility_criteria text
);

CREATE TABLE DeductionPolicy
(
    policy_id int,
    deduction_reason varchar(100),
    calculation_mode varchar(100)
);

CREATE TABLE PayrollPolicyID
(
    payroll_id int,
    policy_id int
);

CREATE TABLE PayrollLog
(
    payroll_log_id int PRIMARY KEY,
    payroll_id int,
    actor varchar(100),
    change_date datetime,
    modification_type varchar(100)
);

CREATE TABLE TaxForm
(
    TaxFormID int PRIMARY KEY,
    jurisdiction varchar(100),
    validity_period datetime,
    form_content text
);

CREATE TABLE PayGrade
(
    PayGradeID int PRIMARY KEY,
    grade_name varchar(50),
    min_salary decimal(18,2),
    max_salary decimal(18,2)
);

CREATE TABLE PayrollPeriod
(
    PayrollPeriodID int PRIMARY KEY,
    payroll_id int,
    start_date datetime,
    end_date datetime,
    status varchar(50)
);

CREATE TABLE Notification
(
    NotificationID int PRIMARY KEY,
    mesage_content text,
    timestamp datetime,
    urgency varchar(50),
    read_status bit,
    notification_type varchar(100)
);

CREATE TABLE EmployeeNotification
(
    employee_id int,
    notification_id int,
    delivery_status varchar(50),
    delivered_at datetime
);

CREATE TABLE EmployeeHierarchy
(
    employee_id int,
    manager_id int,
    hierarchy_level int
);

CREATE TABLE Device
(
    DeviceID int PRIMARY KEY,
    device_type varchar(100),
    terminal_id varchar(100) UNIQUE,
    latitude decimal(9,6),
    longitude decimal(9,6),
    employee_id int
);

CREATE TABLE AttendanceSource
(
    attendance_id int,
    device_id int,
    source_type varchar(100),
    latitude decimal(9,6),
    longitude decimal(9,6),
    recorded_at datetime
);

CREATE TABLE ShiftCycle
(
    CycleID int PRIMARY KEY,
    cycle_name varchar(100),
    description text
);

CREATE TABLE ShiftCycleAssignment
(
    cycle_id int,
    shift_id int,
    order_number int
);

CREATE TABLE ApprovalWorkflow
(
    WorkflowID int PRIMARY KEY,
    workflow_type varchar(100),
    threshold_amount decimal(18,2),
    approved_role varchar(100),
    created_by int,
    status varchar(50)
);

CREATE TABLE ApprovalWorkflowStep
(
    workflow_id int,
    step_number int,
    role_id int,
    action_required varchar(100)
);

CREATE TABLE ManagerNotes
(
    NoteID int PRIMARY KEY,
    employee_id int,
    manager_id int,
    note_content text,
    created_at datetime
);
CREATE TABLE AttendancePolicy (
    PolicyID INT PRIMARY KEY IDENTITY(1,1),
    policy_name VARCHAR(100) NOT NULL,
    policy_type VARCHAR(50) NOT NULL,
    description VARCHAR(500),
    parameters VARCHAR(1000),
    effective_date DATETIME NOT NULL DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL DEFAULT 'Active'
);

-- ========================================
-- FOREIGN KEY CONSTRAINTS
-- ========================================

ALTER TABLE HRAdministrator
ADD CONSTRAINT FK_HRAdministrator_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE SystemAdministrator
ADD CONSTRAINT FK_SystemAdministrator_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE PayrollSpecialist
ADD CONSTRAINT FK_PayrollSpecialist_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE LineManager
ADD CONSTRAINT FK_LineManager_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE Department
ADD CONSTRAINT FK_Department_Employee FOREIGN KEY (department_head_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeSkill
ADD CONSTRAINT FK_EmployeeSkill_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeSkill
ADD CONSTRAINT FK_EmployeeSkill_Skill FOREIGN KEY (skill_id) REFERENCES Skill(SkillID);
ALTER TABLE EmployeeVerification
ADD CONSTRAINT FK_EmployeeVerification_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeVerification
ADD CONSTRAINT FK_EmployeeVerification_Verification FOREIGN KEY (verification_id) REFERENCES Verification(VerificationID);
ALTER TABLE EmployeeRole
ADD CONSTRAINT FK_EmployeeRole_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeRole
ADD CONSTRAINT FK_EmployeeRole_Role FOREIGN KEY (role_id) REFERENCES Role(RoleID);
ALTER TABLE RolePermission
ADD CONSTRAINT FK_RolePermission_Role FOREIGN KEY (role_id) REFERENCES Role(RoleID);
ALTER TABLE FullTimeContract
ADD CONSTRAINT FK_FullTimeContract_Contract FOREIGN KEY (contract_id) REFERENCES Contract(ContractID);
ALTER TABLE PartTimeContract
ADD CONSTRAINT FK_PartTimeContract_Contract FOREIGN KEY (contract_id) REFERENCES Contract(ContractID);
ALTER TABLE ConsultantContract
ADD CONSTRAINT FK_ConsultantContract_Contract FOREIGN KEY (contract_id) REFERENCES Contract(ContractID);
ALTER TABLE InternshipContract
ADD CONSTRAINT FK_InternshipContract_Contract FOREIGN KEY (contract_id) REFERENCES Contract(ContractID);
ALTER TABLE Termination
ADD CONSTRAINT FK_Termination_Contract FOREIGN KEY (contract_id) REFERENCES Contract(ContractID);
ALTER TABLE Reimbursement
ADD CONSTRAINT FK_Reimbursement_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE Mission
ADD CONSTRAINT FK_Mission_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE Mission
ADD CONSTRAINT FK_Mission_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
ALTER TABLE VacationLeave
ADD CONSTRAINT FK_VacationLeave_Leave FOREIGN KEY (leave_id) REFERENCES Leave(LeaveID);
ALTER TABLE SickLeave
ADD CONSTRAINT FK_SickLeave_Leave FOREIGN KEY (leave_id) REFERENCES Leave(LeaveID);
ALTER TABLE ProbationLeave
ADD CONSTRAINT FK_ProbationLeave_Leave FOREIGN KEY (leave_id) REFERENCES Leave(LeaveID);
ALTER TABLE HolidayLeave
ADD CONSTRAINT FK_HolidayLeave_Leave FOREIGN KEY (leave_id) REFERENCES Leave(LeaveID);
ALTER TABLE LeaveRequest
ADD CONSTRAINT FK_LeaveRequest_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE LeaveRequest
ADD CONSTRAINT FK_LeaveRequest_Leave FOREIGN KEY (leave_id) REFERENCES Leave(LeaveID);
ALTER TABLE LeaveEntitlement
ADD CONSTRAINT FK_LeaveEntitlement_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE LeaveEntitlement
ADD CONSTRAINT FK_LeaveEntitlement_Leave FOREIGN KEY (leave_type_id) REFERENCES Leave(LeaveID);
ALTER TABLE LeaveDocument
ADD CONSTRAINT FK_LeaveDocument_LeaveRequest FOREIGN KEY (leave_request_id) REFERENCES LeaveRequest(RequestID);
ALTER TABLE Attendance
ADD CONSTRAINT FK_Attendance_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE Attendance
ADD CONSTRAINT FK_Attendance_Exception FOREIGN KEY (exception_id) REFERENCES Exception(ExceptionID);
ALTER TABLE AttendanceLog
ADD CONSTRAINT FK_AttendanceLog_Attendance FOREIGN KEY (attendance_id) REFERENCES Attendance(AttendanceID);
ALTER TABLE AttendanceCorrectionRequest
ADD CONSTRAINT FK_AttendanceCorrectionRequest_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE AttendanceCorrectionRequest
ADD CONSTRAINT FK_AttendanceCorrectionRequest_RecommendedBy FOREIGN KEY (recommended_by) REFERENCES Employee(EmployeeID);
ALTER TABLE ShiftSchedule
ADD CONSTRAINT FK_ShiftSchedule_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeException
ADD CONSTRAINT FK_EmployeeException_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeException
ADD CONSTRAINT FK_EmployeeException_Exception FOREIGN KEY (exception_id) REFERENCES Exception(ExceptionID);
ALTER TABLE Payroll
ADD CONSTRAINT FK_Payroll_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE SalaryType
ADD CONSTRAINT FK_SalaryType_Currency FOREIGN KEY (currency) REFERENCES Currency(CurrencyCode);
ALTER TABLE HourlySalaryType
ADD CONSTRAINT FK_HourlySalaryType_SalaryType FOREIGN KEY (salary_type_id) REFERENCES SalaryType(SalaryTypeID);
ALTER TABLE MonthlySalaryType
ADD CONSTRAINT FK_MonthlySalaryType_SalaryType FOREIGN KEY (salary_type_id) REFERENCES SalaryType(SalaryTypeID);
ALTER TABLE ContractSalaryType
ADD CONSTRAINT FK_ContractSalaryType_SalaryType FOREIGN KEY (salary_type_id) REFERENCES SalaryType(SalaryTypeID);
ALTER TABLE AllowanceDeduction
ADD CONSTRAINT FK_AllowanceDeduction_Payroll FOREIGN KEY (payroll_id) REFERENCES Payroll(PayrollID);
ALTER TABLE AllowanceDeduction
ADD CONSTRAINT FK_AllowanceDeduction_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE AllowanceDeduction
ADD CONSTRAINT FK_AllowanceDeduction_Currency FOREIGN KEY (currency) REFERENCES Currency(CurrencyCode);
ALTER TABLE OvertimePolicy
ADD CONSTRAINT FK_OvertimePolicy_PayrollPolicy FOREIGN KEY (policy_id) REFERENCES PayrollPolicy(PolicyID);
ALTER TABLE LatenessPolicy
ADD CONSTRAINT FK_LatenessPolicy_PayrollPolicy FOREIGN KEY (policy_id) REFERENCES PayrollPolicy(PolicyID);
ALTER TABLE BonusPolicy
ADD CONSTRAINT FK_BonusPolicy_PayrollPolicy FOREIGN KEY (policy_id) REFERENCES PayrollPolicy(PolicyID);
ALTER TABLE DeductionPolicy
ADD CONSTRAINT FK_DeductionPolicy_PayrollPolicy FOREIGN KEY (policy_id) REFERENCES PayrollPolicy(PolicyID);
ALTER TABLE PayrollPolicyID
ADD CONSTRAINT FK_PayrollPolicyID_Payroll FOREIGN KEY (payroll_id) REFERENCES Payroll(PayrollID);
ALTER TABLE PayrollPolicyID
ADD CONSTRAINT FK_PayrollPolicyID_PayrollPolicy FOREIGN KEY (policy_id) REFERENCES PayrollPolicy(PolicyID);
ALTER TABLE PayrollLog
ADD CONSTRAINT FK_PayrollLog_Payroll FOREIGN KEY (payroll_id) REFERENCES Payroll(PayrollID);
ALTER TABLE PayrollPeriod
ADD CONSTRAINT FK_PayrollPeriod_Payroll FOREIGN KEY (payroll_id) REFERENCES Payroll(PayrollID);
ALTER TABLE EmployeeNotification
ADD CONSTRAINT FK_EmployeeNotification_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeNotification
ADD CONSTRAINT FK_EmployeeNotification_Notification FOREIGN KEY (notification_id) REFERENCES Notification(NotificationID);
ALTER TABLE EmployeeHierarchy
ADD CONSTRAINT FK_EmployeeHierarchy_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeHierarchy
ADD CONSTRAINT FK_EmployeeHierarchy_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
ALTER TABLE Device
ADD CONSTRAINT FK_Device_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE AttendanceSource
ADD CONSTRAINT FK_AttendanceSource_Attendance FOREIGN KEY (attendance_id) REFERENCES Attendance(AttendanceID);
ALTER TABLE AttendanceSource
ADD CONSTRAINT FK_AttendanceSource_Device FOREIGN KEY (device_id) REFERENCES Device(DeviceID);
ALTER TABLE ShiftCycleAssignment
ADD CONSTRAINT FK_ShiftCycleAssignment_ShiftCycle FOREIGN KEY (cycle_id) REFERENCES ShiftCycle(CycleID);
ALTER TABLE ShiftCycleAssignment
ADD CONSTRAINT FK_ShiftCycleAssignment_ShiftSchedule FOREIGN KEY (shift_id) REFERENCES ShiftSchedule(ShiftID);
ALTER TABLE ApprovalWorkflow
ADD CONSTRAINT FK_ApprovalWorkflow_CreatedBy FOREIGN KEY (created_by) REFERENCES Employee(EmployeeID);
ALTER TABLE ApprovalWorkflowStep
ADD CONSTRAINT FK_ApprovalWorkflowStep_Workflow FOREIGN KEY (workflow_id) REFERENCES ApprovalWorkflow(WorkflowID);
ALTER TABLE ApprovalWorkflowStep
ADD CONSTRAINT FK_ApprovalWorkflowStep_Role FOREIGN KEY (role_id) REFERENCES Role(RoleID);
ALTER TABLE ManagerNotes
ADD CONSTRAINT FK_ManagerNotes_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE ManagerNotes
ADD CONSTRAINT FK_ManagerNotes_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_Position FOREIGN KEY (position_id) REFERENCES Position(PositionID);
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_PayGrade FOREIGN KEY (paygrade_id) REFERENCES PayGrade(PayGradeID);
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_TaxForm FOREIGN KEY (taxform_id) REFERENCES TaxForm(TaxFormID);
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_Department FOREIGN KEY (department_id) REFERENCES Department(DepartmentID);
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_SalaryType FOREIGN KEY (salary_type_id) REFERENCES SalaryType(SalaryTypeID);
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_Contract FOREIGN KEY (contract_id) REFERENCES Contract(ContractID);
