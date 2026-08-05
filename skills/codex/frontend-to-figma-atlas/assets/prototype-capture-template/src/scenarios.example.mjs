const viewport = { width: 1440, height: 900 }

export const captureConfig = {
  auth: {
    loginRoute: '/login',
    // Optional: set only when the demo accepts a JSON user object in localStorage.
    localStorageKey: '',
  },
}

const users = {
  admin: {
    id: 'demo-admin',
    name: '演示管理员',
    roleKey: 'demo_admin',
    roleName: '演示全权限账户',
  },
}

const click = (target, options = {}) => ({
  type: 'click',
  target,
  locator: {
    by: options.by || 'role',
    role: options.role || 'button',
    name: options.name || target,
    exact: options.exact ?? false,
  },
})

const textClick = (target, exact = true) => ({
  type: 'click',
  target,
  locator: { by: 'text', text: target, exact },
})

const fill = (target, value) => ({
  type: 'fill',
  target,
  value,
  locator: { by: 'placeholder', text: target, exact: true },
})

const scroll = (target) => ({
  type: 'scrollIntoView',
  target,
  locator: { by: 'text', text: target, exact: true },
})

function scene(id, module, flow, roleKey, screenName, stateName, route, screenshotName, extra = {}) {
  const role = users[roleKey]?.roleName || roleKey
  return {
    id,
    module,
    flow,
    role,
    roleKey,
    screenName,
    stateName,
    route,
    viewport,
    preconditions: extra.preconditions || [`身份：${role}`],
    actions: extra.actions || [],
    waitFor: extra.waitFor || screenName,
    expectedText: extra.expectedText || [screenName],
    screenshotName,
    notes: extra.notes || '',
    expectedOutcome: extra.expectedOutcome || 'success',
  }
}

export const scenarios = [
  scene('01-01', '登录与身份', '进入系统', 'admin', '选择工作身份', '默认状态', '/login', '01-01-登录与身份-选择工作身份-默认状态.png'),
  scene('02-01', '首页', '查看工作台', 'admin', '首页工作台', '默认状态', '/dashboard', '02-01-首页-首页工作台-默认状态.png'),
  scene('02-02', '首页', '查看工作台', 'admin', '筛选面板', '展开状态', '/dashboard', '02-02-首页-筛选面板-展开状态.png', {
    actions: [click('筛选')],
    expectedText: ['筛选', '重置'],
  }),
]

export const routeInventory = [
  { route: '/login', page: 'LoginPage', module: '登录与身份', kind: '直接页面', roles: '全部', states: '默认状态' },
  { route: '/dashboard', page: 'DashboardPage', module: '首页', kind: '主页面', roles: '已登录角色', states: '默认、筛选' },
]

export { click, fill, scroll, textClick, users }
