// --- STATE MANAGEMENT ---
let currentStudentRecords = [
    { code: "CS-101", title: "Introduction to Computer Science", credits: 4, grade: "A", status: "Completed" },
    { code: "MATH-210", title: "Calculus II", credits: 4, grade: "A-", status: "Completed" },
    { code: "IP-302", title: "Internet Programming", credits: 3, grade: "B+", status: "In Progress" },
    { code: "PHYS-150", title: "Physics for Computing", credits: 4, grade: "Pending", status: "In Progress" }
];

// --- VIEW NAVIGATION (SPA ROUTING) ---
const loginScreen = document.getElementById('login-screen');
const mainAppLayout = document.getElementById('main-app');
const loginForm = document.getElementById('login-form');
const logoutBtn = document.getElementById('logout-btn');

// Handle Sign In Simulation
loginForm.addEventListener('submit', (e) => {
    e.preventDefault();
    loginScreen.classList.remove('active-view');
    loginScreen.classList.add('hidden');
    
    mainAppLayout.classList.remove('hidden');
    renderAcademicRecords(); // Initial data paint
});

// Handle Logout Simulation
logoutBtn.addEventListener('click', () => {
    mainAppLayout.classList.add('hidden');
    loginScreen.classList.remove('hidden');
    loginScreen.classList.add('active-view');
});

// Sidebar Navigation Link Swapping
const menuItems = document.querySelectorAll('.menu-item');
const pageViews = document.querySelectorAll('.page-view');

menuItems.forEach(item => {
    item.addEventListener('click', (e) => {
        e.preventDefault();
        
        // Remove active class from all nav items
        menuItems.forEach(i => i.classList.remove('active'));
        // Add active to current target
        item.classList.add('active');
        
        // Hide all page views
        pageViews.forEach(page => page.classList.add('hidden'));
        
        // Show target page
        const targetPageId = item.getAttribute('data-target');
        document.getElementById(targetPageId).classList.remove('hidden');
    });
});

// --- ACADEMIC RECORDS ACTIONS ---
const recordsTableBody = document.getElementById('records-table-body');
const addCourseBtn = document.getElementById('add-course-btn');

function renderAcademicRecords() {
    recordsTableBody.innerHTML = '';
    
    currentStudentRecords.forEach(record => {
        const row = document.createElement('tr');
        
        const statusBadgeClass = record.status === 'Completed' ? 'badge-success' : 'badge-warning';
        
        row.innerHTML = `
            <td><strong>${record.code}</strong></td>
            <td>${record.title}</td>
            <td>${record.credits}</td>
            <td>${record.grade}</td>
            <td><span class="badge ${statusBadgeClass}">${record.status}</span></td>
        `;
        recordsTableBody.appendChild(row);
    });
}

// Simulated interaction: append new course to local array and re-render view state
addCourseBtn.addEventListener('click', () => {
    const courseCodes = ['ENG-102', 'DAT-401', 'SYS-220', 'NET-110'];
    const courseTitles = ['Technical Writing', 'Database Systems', 'System Analysis', 'Networking Basics'];
    
    const randomIdx = Math.floor(Math.random() * courseCodes.length);
    
    const newRecord = {
        code: courseCodes[randomIdx],
        title: courseTitles[randomIdx],
        credits: 3,
        grade: 'Pending',
        status: 'In Progress'
    };
    
    currentStudentRecords.push(newRecord);
    renderAcademicRecords();
});

// Profile modification visual affirmation
const profileFormButton = document.querySelector('.save-btn');
if(profileFormButton) {
    profileFormButton.addEventListener('click', () => {
        alert('Student Profile configuration updated locally successfully.');
    });
}