export const TABLE_GROUPS = [
  {
    id: 'people',
    label: 'אנשים',
    tables: [
      'tbl_customer',
      'tbl_admin',
      'tbl_follows',
      'tbl_artist_business_map',
      'tbl_contact_us',
      'tbl_roles',
      'tbl_access_permission',
    ],
  },
  {
    id: 'content',
    label: 'תוכן',
    tables: [
      'tbl_post',
      'tbl_post_likes',
      'tbl_saved_post',
      'tbl_saved_business',
      'tbl_styles',
      'tbl_styles1',
      'tbl_pages',
      'tbl_notifications',
    ],
  },
  {
    id: 'commerce',
    label: 'מסחר',
    tables: ['tbl_subscription', 'tbl_ios_subscription_ipn', 'tbl_request'],
  },
  {
    id: 'moderation',
    label: 'פיקוח',
    tables: ['tbl_report_posts', 'tbl_report_users'],
  },
  {
    id: 'system',
    label: 'מערכת',
    tables: [
      'tbl_settings',
      'tbl_app_log',
      'tbl_login_error_db',
      'debug_app_data',
      'ci_sessions',
    ],
  },
];

export const TABLE_LABELS = {
  ci_sessions: 'Sessions',
  debug_app_data: 'Debug reports',
  tbl_access_permission: 'Access permissions',
  tbl_admin: 'Admins',
  tbl_app_log: 'App logs',
  tbl_artist_business_map: 'Artist–studio map',
  tbl_contact_us: 'Contact messages',
  tbl_customer: 'Customers',
  tbl_follows: 'Follows',
  tbl_ios_subscription_ipn: 'iOS subscription IPN',
  tbl_login_error_db: 'Login errors',
  tbl_notifications: 'Notifications',
  tbl_pages: 'Pages',
  tbl_post: 'Posts',
  tbl_post_likes: 'Post likes',
  tbl_report_posts: 'Reported posts',
  tbl_report_users: 'Reported users',
  tbl_request: 'Requests',
  tbl_roles: 'Roles',
  tbl_saved_business: 'Saved businesses',
  tbl_saved_post: 'Saved posts',
  tbl_settings: 'Settings',
  tbl_styles: 'Styles',
  tbl_styles1: 'Styles (legacy)',
  tbl_subscription: 'Subscriptions',
};

export function friendlyName(table) {
  return TABLE_LABELS[table] || table.replace(/^tbl_/, '').replace(/_/g, ' ');
}
