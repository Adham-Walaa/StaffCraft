create database MILESTONE2;
create Table Employee 
(
	EmployeeID int Primary Key,
	first_name varchar(50),
	last_name varchar(50),
	full_name As (first_name + ' ' + last_name) PERSISTED,
	national_id varchar(20) Unique,
	date_of_birth datetime,
	country_of_birth varchar(50),
	phone varchar(15),
	email varchar(100) Unique,
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
	is_active bit Default 1,
	profile_completion_percentage int Check (profile_completion_percentage between 0 and 100),
	--Foreign Keys
	--department_id int Foreign Key References Department(DepartmentID),
	--position_id int Foreign Key References Position(PositionID),
	--manager_id int Foreign Key References Employee(EmployeeID),
	--contract_id int Foreign Key References Contract(ContractID),
	--tax_form_id int Foreign Key References TaxForm(TaxFormID),
	--salary_type_id int Foreign Key References SalaryType(SalaryTypeID),
	--pay_grade_id int Foreign Key References PayGrade(PayGradeID),
);
create Table HRAdministrator 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	approval_level varchar(50),
	record_access_scope varchar(100),
	document_validation_rights bit,
);
create Table SystemAdministrator 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	system_privilege_level varchar(50),
	configurable_fields text,
	audit_visibility_scope varchar(100),
);
create Table PayrollSpecialist 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	assigned_region varchar(100),
	processing_frequency varchar(50),
	last_processed_period datetime, 
);
create Table LineManager 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	team_size int,
	supervised_departments varchar(200),
	approval_limit decimal(18,2),
);
create Table Position 
(
	PositionID int Primary Key,
	position_title varchar(100),
	responsibilities text,
	status varchar(50),
);
create Table Department 
(
	DepartmentID int Primary Key,
	department_name varchar(100),
	purpose text,
	department_head_id int Foreign Key References Employee(EmployeeID),
);
create Table Skill 
(
	SkillID int  Primary Key,
	skill_name varchar(100),
	description text,
);
create Table EmployeeSkill 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	skill_id int Foreign Key References Skill(SkillID),
	proficiency_level varchar(50),
);
create Table Verification 
(
	VerificationID int  Primary Key,
	verification_type varchar(100),
	issuer varchar(100),
	issue_date date,
	expiry_period date,
);
create Table EmployeeVerification 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	verification_id int Foreign Key References Verification(VerificationID),
);
create Table Role 
(
	RoleID int  Primary Key,
	role_name varchar(100),
	purpose text,
);
create Table EmployeeRole 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	role_id int Foreign Key References Role(RoleID),
	assigned_date datetime,
);
create Table RolePermission 
(
	role_id int Foreign Key References Role(RoleID),
	permission_name varchar(100),
	allowed_action varchar(100),
);
create Table Contract 
(
	ContractID int  Primary Key,
	type varchar(100),
	start_date datetime,
	end_date datetime,
	current_state varchar(50),
);
create Table FullTimeContract 
(
	contract_id int Foreign Key References Contract(ContractID),
	leave_entitlement int,
	insurance_eligibility bit,
	weekly_working_hours int,
);
create Table PartTimeContract 
(
	contract_id int Foreign Key References Contract(ContractID),
	working_hours int,
	hourly_rate decimal(18,2),
);
create Table ConsultantContract 
(
	contract_id int Foreign Key References Contract(ContractID),
	project_scope text,
	fees decimal(18,2),
	payment_schedule varchar(100),
);
create Table InternshipContract 
(
	contract_id int Foreign Key References Contract(ContractID),
	mentoring varchar(200),
	evaluation text,
	stipend_related decimal(18,2),
);
create Table Insurance 
(
	InsuranceID int  Primary Key,
	type varchar(100),
	contribution_rate decimal(5,2),
	coverage text,
);
create Table Termination 
(
	TerminationID int  Primary Key,
	date date,
	reason text,
	contract_id int Foreign Key References Contract(ContractID),
);
create Table Reimbursement 
(
	ReimbursementID int  Primary Key,
	type varchar(100),
	claim_type varchar(100),
	approval_date datetime,
	current_status varchar(50),
	employee_id int Foreign Key References Employee(EmployeeID),
);
create Table Mission 
(
	MissionID int  Primary Key,
	destination varchar(100),
	start_date datetime,
	end_date datetime,
	status varchar(50),
	employee_id int Foreign Key References Employee(EmployeeID),
	manager_id int Foreign Key References Employee(EmployeeID),
);
create Table Leave 
(
	LeaveID int  Primary Key,
	leave_type varchar(100),
	leave_description text,
);
create Table VacationLeave 
(
	leave_id int Foreign Key References Leave(LeaveID),
	carry_over_days int,
	approving_manager varchar(100),
);
create Table SickLeave 
(
	leave_id int Foreign Key References Leave(LeaveID),
	medical_certificate_required bit,
	physician_id int, 
);
create Table ProbationLeave 
(
	leave_id int Foreign Key References Leave(LeaveID),
	eligibility_start_date datetime,
	probation_period int,
);
create Table HolidayLeave 
(
	leave_id int Foreign Key References Leave(LeaveID),
	holiday_name varchar(100),
	official_recognition bit,
	regional_scope varchar(100),
);
create Table LeavePolicy 
(
	PolicyID int  Primary Key,
	name varchar(100),
	purpose text,
	eligibility_rules text,
	notice_period datetime, --check if date or int
	special_leave_type varchar(100),
	reset_on_new_year bit,
);
create Table LeaveRequest 
(
	RequestID int  Primary Key,
	employee_id int Foreign Key References Employee(EmployeeID),
	leave_id int Foreign Key References Leave(LeaveID),
	justification text,
	duration int,
	approval_timing datetime, --check if date or int
	status varchar(50),
);
create Table LeaveEntitlement 
(
	employee_id int Foreign Key References Employee(EmloyeeID),
	leave_type_id int Foreign Key References Leave(LeaveID),
	entitlement int,
);
create Table LeaveDocument 
(
	DocumentID int Primary Key,
	leave_request_id int Foreign Key References LeaveRequest(RequestID),
	file_path varchar(200),
	uploaded_at datetime,
);
create Table Attendance 
(
	AttendanceID int Primary Key,
	employee_id int Foreign Key References Employee(EmployeeID),
	shift_id int Foreign Key References Shift(ShiftID),
	entry_time time,
	exit_time time,
	duration int,
	login_method varchar(50),
	logout_method varchar(50),
	exception_id int Foreign Key References AttendanceException(ExceptionID),
);
create Table AttendanceLog 
(
	AttendanceLogID int Primary Key,
	attendance_id int Foreign Key References Attendance(AttendanceID),
	actor varchar(100),
	timestamp datetime,
	reason text,
);
create Table AttendanceCorrectionRequest 
(
	RequestID int Primary Key,
	employee_id int Foreign Key References Employee(EmployeeID),
	date date,
	correction_type varchar(100),
	reason text,
	status varchar(50),
	recommended_by int Foreign Key References Employee(EmployeeID),
);
create Table ShiftSchedule 
(
	ShiftID int Primary Key,
	employee_id int Foreign Key References Employee(EmployeeID),
	shift_id int Foreign Key References Shift(ShiftID),
	start_date datetime,
	end_date datetime,
	status varchar(50),
);
create Table Exception
(
	ExceptionID int Primary Key,
	name varchar(100),
	category varchar(100),
	date datetime,
	status varchar(50),
);
create Table EmployeeException 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	exception_id int Foreign Key References Exception(ExceptionID),
);
create Table Payroll 
(
	PayrollID int Primary Key,
	employee_id int Foreign Key References Employee(EmployeeID),
	taxes decimal(18,2),
	period_start datetime,
	period_end datetime,
	base_amount decimal(18,2),
	adjustments decimal(18,2),
	contributions decimal(18,2),
	actual_pay decimal(18,2),
	net_salary decimal(18,2),
	payment_date datetime,
);
create Table Currency 
(
	CurrencyCode varchar(10) Primary Key,
	currency_name varchar(50),
	exchange_rate decimal(18,4),
	created_date datetime,
	last_updated datetime,
);
create Table SalaryType 
(
	SalaryTypeID int Primary Key,
	type varchar(100),
	payment_frequency varchar(50),
	currency varchar(10) Foreign Key References Currency(currency_name),
);
create Table HourlySalaryType 
(
	salary_type_id int Foreign Key References SalaryType(SalaryTypeID),
	hourly_rate decimal(18,2),
	max_monthly_hours int,
);
create Table MonthlySalaryType 
(
	salary_type_id int Foreign Key References SalaryType(SalaryTypeID),
	tax_rule varchar(100),
	contribution_scheme varchar(100),
);
create Table ContractSalaryType 
(
	salary_type_id int Foreign Key References SalaryType(SalaryTypeID),
	contract_value decimal(18,2),
	installement_details varchar(200),
);
create Table AllowanceDeduction 
(
	AllowanceDeductionID int Primary Key,
	payroll_id int Foreign Key References Payroll(PayrollID),
	employee_id int Foreign Key References Employee(EmployeeID),
	type varchar(50),
	amount decimal(18,2),
	currency varchar(10) Foreign Key References Currency(currency_name),
	duration int,
	timezone varchar(50),
);
create Table PayrollPolicy 
(
	PolicyID int Primary Key,
	effective_date datetime,
	type varchar(100),
	description text,
);
create Table OvertimePolicy 
(
	policy_id int Foreign Key References PayrollPolicy(PolicyID),
	weekday_rate_multiplier decimal(5,2),
	weekend_rate_multiplier decimal(5,2),
	max_hours_per_month int,
);
create Table LatenessPolicy 
(
	policy_id int Foreign Key References PayrollPolicy(PolicyID),
	grace_period_minutes int,
	deduction_rate decimal(5,2),
);
create Table BonusPolicy 
(
	policy_id int Foreign Key References PayrollPolicy(PolicyID),
	bonus_type varchar(100),
	eligibility_criteria text,
);
create Table DeductionPolicy 
(
	policy_id int Foreign Key References PayrollPolicy(PolicyID),
	deduction_reason varchar(100),
	calculation_mode varchar(100),
);
create Table PayrollPolicyID 
(
	payroll_id int Foreign Key References Payroll(PayrollID),
	policy_id int Foreign Key References PayrollPolicy(PolicyID),
);
create Table PayrollLog 
(
	payroll_log_id int Primary Key,
	payroll_id int Foreign Key References Payroll(PayrollID),
	actor varchar(100),
	change_date datetime,
	modification_type varchar(100),
);
create Table TaxForm 
(
	TaxFormID int Primary Key,
	jurisdiction varchar(100),
	validity_period datetime,
	form_content text,
);
create Table PayGrade 
(
	PayGradeID int Primary Key,
	grade_name varchar(50),
	min_salary decimal(18,2),
	max_salary decimal(18,2),
);
create Table PayrollPeriod 
(
	PayrollPeriodID int Primary Key,
	payroll_id int Foreign Key References Payroll(PayrollID),
	start_date datetime,
	end_date datetime,
	status varchar(50),
);
create Table Notification 
(
	NotificationID int Primary Key,
	mesage_content text,
	timestamp datetime,
	urgency varchar(50),
	read_status bit,
	notification_type varchar(100),
);
create Table EmployeeNotification 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	notification_id int Foreign Key References Notification(NotificationID),
	delivery_status varchar(50),
	delivered_at datetime,
);
create Table EmployeeHierarchy 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	manager_id int Foreign Key References Employee(EmployeeID),
	hierarchy_level int,
);
create Table Device 
(
	DeviceID int Primary Key,
	device_type varchar(100),
	terminal_id varchar(100) Unique, --check if unique or no
	latitude decimal(9,6),
	longitude decimal(9,6),
	employee_id int Foreign Key References Employee(EmployeeID),	
);
create Table AttendanceSource 
(
	attendance_id int Foreign Key References Attendance(AttendanceID),
	device_id int Foreign Key References Device(DeviceID),
	source_type varchar(100),
	latitude decimal(9,6),
	longitude decimal(9,6),
	recorded_at datetime,
);
create Table ShiftCycle 
(
	CycleID int Primary Key,
	cycle_name varchar(100),
	description text,
);
create Table ShiftCycleAssignment 
(
	cycle_id int Foreign Key References ShiftCycle(CycleID),
	shift_id int Foreign Key References Shift(ShiftID),
	order_number int,
);
create Table ApprovalWorkflow 
(
	WorkflowID int Primary Key,
	workflow_type varchar(100),
	threshold_amount decimal(18,2),
	approved_role varchar(100),
	created_by int Foreign Key References Employee(EmployeeID), 
	status varchar(50),
);
create Table ApprovalWorkflowStep 
(
	workflow_id int Foreign Key References ApprovalWorkflow(WorkflowID),
	step_number int,
	role_id int Foreign Key References Role(RoleID),
	action_required varchar(100),
);
create Table ManagerNotes
(
	NoteID int Primary Key,
	employee_id int Foreign Key References Employee(EmployeeID),
	manager_id int Foreign Key References Employee(EmployeeID),
	note_content text,
	created_at datetime,
);

ALTER TABLE HRAdministrator ADD CONSTRAINT FK_HRAdministrator_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE SystemAdministrator ADD CONSTRAINT FK_SystemAdministrator_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE PayrollSpecialist ADD CONSTRAINT FK_PayrollSpecialist_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE LineManager ADD CONSTRAINT FK_LineManager_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE Department ADD CONSTRAINT FK_Department_Employee FOREIGN KEY (department_head_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeSkill ADD CONSTRAINT FK_EmployeeSkill_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeSkill ADD CONSTRAINT FK_EmployeeSkill_Skill FOREIGN KEY (skill_id) REFERENCES Skill(SkillID);
ALTER TABLE EmployeeVerification ADD CONSTRAINT FK_EmployeeVerification_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeVerification ADD CONSTRAINT FK_EmployeeVerification_Verification FOREIGN KEY (verification_id) REFERENCES Verification(VerificationID);
ALTER TABLE EmployeeRole ADD CONSTRAINT FK_EmployeeRole_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeRole ADD CONSTRAINT FK_EmployeeRole_Role FOREIGN KEY (role_id) REFERENCES Role(RoleID);
ALTER TABLE EmployeeHierarchy ADD CONSTRAINT FK_EmployeeHierarchy_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeHierarchy ADD CONSTRAINT FK_EmployeeHierarchy_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
ALTER TABLE Mission ADD CONSTRAINT FK_Mission_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE Mission ADD CONSTRAINT FK_Mission_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
ALTER TABLE LeaveRequest ADD CONSTRAINT FK_LeaveRequest_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE LeaveRequest ADD CONSTRAINT FK_LeaveRequest_Leave FOREIGN KEY (leave_id) REFERENCES Leave(LeaveID);
ALTER TABLE EmployeeNotification ADD CONSTRAINT FK_EmployeeNotification_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE EmployeeNotification ADD CONSTRAINT FK_EmployeeNotification_Notification FOREIGN KEY (notification_id) REFERENCES Notification(NotificationID);
ALTER TABLE Attendance ADD CONSTRAINT FK_Attendance_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE Attendance ADD CONSTRAINT FK_Attendance_Shift FOREIGN KEY (shift_id) REFERENCES Shift(ShiftID);
ALTER TABLE Attendance ADD CONSTRAINT FK_Attendance_Exception FOREIGN KEY (exception_id) REFERENCES AttendanceException(ExceptionID);
ALTER TABLE Payroll ADD CONSTRAINT FK_Payroll_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
ALTER TABLE Payroll ADD CONSTRAINT FK_Payroll_Period FOREIGN KEY (payroll_id) REFERENCES PayrollPeriod(PayrollID);

