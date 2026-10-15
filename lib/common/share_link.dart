/// r00tvpn: the group a profile made of share links lists its proxies in, as
/// the desktop app names it.
const shareLinkGroupName = 'Серверы';

/// A profile of [proxies] read from share links. The links carry no groups or
/// rules, and with no rule the core sends every connection direct, so the
/// proxies go into one group that every connection matches.
Map<String, dynamic> shareLinkConfig(List<Map<String, dynamic>> proxies) => {
  'proxies': proxies,
  'proxy-groups': [
    {
      'name': shareLinkGroupName,
      'type': 'select',
      'proxies': [for (final proxy in proxies) proxy['name']],
    },
  ],
  'rules': ['MATCH,$shareLinkGroupName'],
};
