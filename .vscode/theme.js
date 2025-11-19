// const logger = (() => {
//     const logPrefix = '[theme]';
//     return {
//         log: (...args) => console.log(logPrefix, ...args),
//         warn: (...args) => console.warn(logPrefix, ...args),
//         error: (...args) => console.error(logPrefix, ...args),
//     };
// })();

// // Clone the Profile and Settings icons from the activity bar and add them to the titlebar
// function addIconsToTitlebar() {
//     const titlebarRight = document.querySelector('.titlebar-right .actions-container');
//     if (!titlebarRight) {
//         return false;
//     }

//     if (titlebarRight.querySelector('.titlebar-profile-icon') &&
//         titlebarRight.querySelector('.titlebar-settings-icon')) {
//         return true;
//     }

//     const profileIcon = document.querySelector('.part.activitybar .codicon-accounts-view-bar-icon')?.closest('.action-item');
//     const settingsIcon = document.querySelector('.part.activitybar .codicon-settings-view-bar-icon')?.closest('.action-item');

//     // Only proceed if both icons are found
//     if (!profileIcon || !settingsIcon) {
//         return false;
//     }

//     const profileClone = profileIcon.cloneNode(true);
//     const settingsClone = settingsIcon.cloneNode(true);
//     profileClone.classList.add('titlebar-profile-icon');
//     settingsClone.classList.add('titlebar-settings-icon');

//     titlebarRight.querySelectorAll('.titlebar-profile-icon, .titlebar-settings-icon').forEach(el => el.remove());

//     // Separator between the original titlebar and our added icons
//     const separator = document.createElement('div');
//     separator.classList.add('separator');
//     separator.setAttribute('role', 'separator');
//     separator.setAttribute('aria-hidden', 'true');
//     titlebarRight.appendChild(separator);

//     titlebarRight.appendChild(settingsClone);
//     titlebarRight.appendChild(profileClone);

//     profileIcon.style.display = 'none';
//     settingsIcon.style.display = 'none';

//     // logger.log('Successfully added profile and settings icons to titlebar');
//     return true;
// }

// // Try to add icons immediately
// addIconsToTitlebar();

// const persistentObserver = new MutationObserver(() => {
//     addIconsToTitlebar();
// });

// const titlebarRight = document.querySelector('.titlebar-right');
// if (titlebarRight) {
//     persistentObserver.observe(titlebarRight, {
//         childList: true,
//         subtree: true
//     });
//     // logger.log('Persistent observer attached to titlebar');
// } else {
//     const initialObserver = new MutationObserver(() => {
//         const titlebar = document.querySelector('.titlebar-right');
//         if (titlebar) {
//             addIconsToTitlebar();
//             persistentObserver.observe(titlebar, {
//                 childList: true,
//                 subtree: true
//             });
//             initialObserver.disconnect();
//             // logger.log('Titlebar found, persistent observer attached');
//         }
//     });

//     initialObserver.observe(document.body, {
//         childList: true,
//         subtree: true
//     });
// }